#!/usr/bin/env python

# The 'append_schemes.sh' script will download and append schemes to the LSApplicationQueriesSchemes key
# in the final product's Info.plist in a way that preserves your existing schemes and their order.
#
# Follow these steps to run the script during the build:
# - Add a 'New Run Scripts' phase to the target in Xcode. Make sure that it is below the other script phases.
# - Change the 'Run Script' title to something more meaningful, e.g. 'Append Schemes'.
# - Add a line in the script contents to run the append_schemes.sh script,
#   e.g. "${SRCROOT}/Scheme-Management/append_schemes.sh".

from __future__ import print_function
import argparse
import glob
import json
import os
import re
import subprocess
import sys
import tempfile
try:
    from urllib.request import urlopen, Request
    from urllib.error import HTTPError, URLError
except ImportError:
    from urllib2 import urlopen, Request, HTTPError, URLError

CONNECT_TIMEOUT_IN_SECONDS = 5

parser = argparse.ArgumentParser(description="Append schemes to the app's Info.plist at build time.")
parser.add_argument('--plist_file',
                    default=None,
                    help='the destination info.plist file (default: read from the ENV variables set by Xcode)')
parser.add_argument('--schemes_file',
                    default=None,
                    help='the file containing new schemes (default: a file called schemes.txt in the same directory as this script)')
args = parser.parse_args()

# Find plutil binary
try:
    if os.path.exists('/usr/bin/plutil'):
        plutil_binary = '/usr/bin/plutil'
    else:
        plutil_binary = subprocess.check_output(["which", "plutil"])
        if not plutil_binary:
            raise "Empty plutil_binary string"
        plutil_binary = plutil_binary.replace('\n','')
except:
    print("error: Unable to find the 'plutil' binary")
    exit(1)

# Locate and check path to app's Info.plist
if args.plist_file:
    info_plist_path = args.plist_file
else:
    TARGET_BUILD_DIR = os.getenv('TARGET_BUILD_DIR')
    INFOPLIST_PATH = os.getenv('INFOPLIST_PATH')
    if TARGET_BUILD_DIR and INFOPLIST_PATH:
        info_plist_path = TARGET_BUILD_DIR + '/' + INFOPLIST_PATH
    else:
        print("error: Invalid environment variables. No path to info plist.")
        exit(1)

if not os.path.exists(info_plist_path):
    print("error: Missing Info.plist file: " + info_plist_path)
    exit(1)

# Get the app's bundle id
bundle_id = None
try:
    xml = subprocess.check_output([plutil_binary, '-extract', 'CFBundleIdentifier', 'xml1', '-r', '-o', '-', info_plist_path])
    if xml:
        m = re.search('<string>(.*)</string>', str(xml), re.MULTILINE)
        if m:
            bundle_id = m.group(1)
except:
    pass

if not bundle_id:
    print("error: Could not find bundle id in Info.plist")
    exit(1)

# Determine tmp directory
try:
    temp_dir = tempfile.gettempdir()
    if temp_dir:
        temp_dir = temp_dir + '/com.pushspring'
        if not os.path.exists(temp_dir):
            os.mkdir(temp_dir)
except:
    pass

if not temp_dir:
    print("error: Could not find/create tmp directory")
    exit(1)

def download_schemes_file(url, etag):
    result = (None, None)

    request = Request(url)
    request.add_header('Accept-Encoding', 'gzip')
    if etag:
        request.add_header("If-None-Match", etag)

    try:
        response = urlopen(request, None, CONNECT_TIMEOUT_IN_SECONDS)
        if response.getcode() != 304:
            # A quick test that the file contents is valid and not binary
            data = response.read()
            if b'\x00' in data[:100]:
                print('warning: The downloaded schemes file has invalid content')
            else:
                new_etag = response.info().get('ETag').replace('"','')
                new_schemes_file = temp_dir + '/downloaded_schemes.' + new_etag
                try:
                    with open(new_schemes_file, 'wb') as f:
                        f.write(data)
                    result = (new_schemes_file, None)
                except:
                    print("warning: Could not write downloaded schemes to '{0}'".format(new_schemes_file))
    except HTTPError as e:
        if e.code == 304:
            result = (None, True)
        else:
            print("Error downloading schemes file")
    except URLError as e:
        print("Error downloading schemes file")
    except:
        print("Unknown error downloading schemes file")

    return result

def download_schemes(bundle_id):
    # Look for a cached schemes file and download a new one if there is a more recent version
    downloaded_files = glob.glob(temp_dir + '/downloaded_schemes.*')
    downloaded_schemes_file = None
    etag = None
    # Save the current file and use the etag in the request
    if downloaded_files:
        downloaded_schemes_file = downloaded_files[0]
        etag = os.path.splitext(downloaded_schemes_file)[1][1:]

    new_download = None
    if bundle_id:
        url = 'http://public.pushspring.com/publisher_config/' + bundle_id + '_schemes.txt'
        new_download, not_modified = download_schemes_file(url, etag)

    if not (new_download or not_modified):
        url = 'http://public.pushspring.com/publisher_config/schemes.txt'
        new_download, not_modified = download_schemes_file(url, etag)

    if new_download:
        # Cleanup any old files now that we have a new one downloaded
        for to_delete in downloaded_files:
            if to_delete != new_download:
                os.remove(to_delete)
        downloaded_schemes_file = new_download

    return downloaded_schemes_file

def default_schemes():
    schemes = ['ha3af30ed428f87abcb430817e90874dff', 'nflx', 'gsd-vnd.youtube-broad-matching', 'uberauth', 'amp5309dc645b87e01eceec869-ed53e3c0-44fd-11e0-c46f-007af5bd88a0', 'fb2231777543', 'gsd-sportscenter', 'com.googleusercontent.apps.848232511240-dmrj3gba506c9svge2p9gq35p1fg654p', 'snapchat', 'gsd-zillow', 'linkedin-sdk2', 'instagram-capture', 'com.googleusercontent.apps.169314272487-p9ielt8d8oajp6apsvkucvdpe6l87jq5', 'fb40582213222', 'aiv', 'hbogo', 'fb422840351240913', 'watchespn', 'dhc', 'com.googleusercontent.apps.909715398357-e9cien2tdtbltc70qk28l42siab3lrug', 'fb106920676011663', 'kakao5b22eda105685591b7f9890489c353f3', 'bofa', 'line3rdp.com.yelp.yelpiphone', 'wazeapi2', 'tl-b53b50b1', 'imovie1.4', 'fb-messenger-public', 'skype', 'alexa', 'fb-quicksilver-20170322', 'spotifyrunning', 'tl-bfec3c26', 'abcplayer', 'ampaa087af9e3418a5eb2fd2e9-06979b04-2448-11e6-84a1-0086bc74ca0f', 'carscom', 'tl-2f578def', 'autotrader', 'nikeplusrunning-spotify', 'espnfantasy', 'fandangovpr', 'nbctve', 'vk5533723', 'cnn', 'walmart', 'com.att.myatt', 'gsd-move-rdc', 'com.googleusercontent.apps.622419776613-lht7npud8p6rlish1pl9jliaoktdum1e', 'walgreens', 'twitch', 'tl-65ef7807', 'com.paypal.ppclient.touch.v3', 'com.googleusercontent.apps.201895780642-4hpk06gt6tf821vqqn8494dftio6gpfq', 'twcweatherntq2ody1ntc2ntyxnzq2ody1nzi0mzy4nje2rtzfnju2qya', 'redfinwidget', 'amznmp3', 'fb283977468393067', 'offerupapp', 'sportcaster', 'soundhound', 'fb132998943501009', 'com.venmo.touch.v2', 'com.googleusercontent.apps.446009525344-5t9hcdev9ddbfqgk1hkgofdesred4bi1', 'square-register-cross-app', 'amexusea', 'com.geico.widget', 'openlowesitempage', 'yfansports', 'usaamainapp', 'gsd-reservetable-com.contextoptional.opentable-1', 'fb317781228276319', 'houzz.bio', 'expediaflights', 'nbcliveapp', 'com.soundcloud.touchapp.frankified', 'fb221094574568058', 'flydelta-checkin', 'fnn', 'starbucks', 'citiglobal', 'pin1431628prod', 'com.nytimes.nytimes', 'amp2c2b3cd94c2251826b8153f-986c13b4-b094-11e4-53c8-00a426b17dd8', 'myradar', 'nestmobile', 'gsd-eat24iphone', 'aso291890420', 'target-branch', 'fb132284063495269', 'fb155028111300787', 'nflmobile', 'teamstream2', 'cards', 'com.googleusercontent.apps.411123305004-apcqgnc3hp0q0uru7d051hpcu0tshcqs', 'sonos-release', 'bblearn', 'com.lyft.ios.beta.braintree', 'fb629364317128523', 'amp2d2510bf4348acc0ce3f953-37754848-0ab2-11e3-39ec-00a426b17dd8', 'gsd-tripadvisor','XAVMGUARD']
    result = list(filter(lambda x: x != u"XAVMGUARD", schemes))
    print("Using", len(result), "default schemes")
    return result

def load_schemes(new_schemes_path):
    result = []
    try:
        with open(new_schemes_path, 'r') as f:
            for line in f:
                line = line.replace('\r', '')
                line = line.replace('\n', '')
                result.append(u'' + line)
        result = list(filter(lambda x: x != u"XAVMGUARD", result))
        print("Loading", len(result), "schemes from: " + new_schemes_path)
        return result
    except Exception as e:
        print("error: Couldn't load schemes from", new_schemes_path, "with error:", e)
        exit(1)
    except:
        print("error: Couldn't load schemes from", new_schemes_path)
        exit(1)

# Check input file
new_schemes_path = args.schemes_file or download_schemes(bundle_id)
if new_schemes_path and not os.path.exists(new_schemes_path):
    print("error: Missing schemes file: " + new_schemes_path)
    exit(1)

# Load any existing schemes from the app's Info.plist
try:
    print('Loading existing schemes from:', info_plist_path)
    existing_schemes = subprocess.check_output([plutil_binary, '-extract', 'LSApplicationQueriesSchemes', 'json', '-r', '-o', '-', info_plist_path])
    existing_schemes = json.loads(existing_schemes)
    existing_schemes = list(filter(lambda x: x != u"XAVMGUARD", existing_schemes))
    print('Found', len(existing_schemes), 'existing schemes')
except:
    print("Didn't find any existing schemes in Info.plist")
    existing_schemes = []

# Load the PushSpring schemes
new_schemes = []
if new_schemes_path:
    new_schemes = load_schemes(new_schemes_path)
else:
    new_schemes = default_schemes()

# Append the new schemes removing any schemes
# that are already in the app's Info.plist
final_schemes = existing_schemes + new_schemes
final_schemes = [x for i, x in enumerate(final_schemes) if final_schemes.index(x) == i]
print("Found", len(final_schemes) - len(existing_schemes), "new schemes")

final_schemes.append(u"XAVMGUARD")

# Write the schemes back to the app's Info.plist
json_schemes = json.dumps(final_schemes)
json_schemes = json_schemes.replace('"', '\"')
try:
    output = subprocess.check_output([plutil_binary, '-replace', 'LSApplicationQueriesSchemes', '-json', json_schemes, info_plist_path])
    print("Wrote", len(final_schemes) - 1, "to the plist")
    exit(0)
except subprocess.CalledProcessError as e:
    print("error: Writing schemes to plist failed:", e.output)
    exit(e.returncode)
except:
    raise