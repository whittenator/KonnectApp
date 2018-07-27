The 'append_schemes.sh' script will download and append schemes to the LSApplicationQueriesSchemes key
in the final product's Info.plist in a way that preserves your existing schemes and their order.

Follow these steps to run the script during the build:
- Add a new 'Run Scripts' phase to the target in Xcode. Make sure that it is below any other script phases.
- Change the 'Run Script' title for the new phase to something more meaningful, e.g. 'Append Schemes'.
- Add a line in the script contents to run the append_schemes.sh script,
  e.g. if you put the script in a Scheme-Management folder in the root of your project,
  add "${SRCROOT}/Scheme-Management/append_schemes.sh". If you are using CocoaPods add
  "${SRCROOT}/Pods/PushSpring/Scheme-Management/append_schemes.sh".
