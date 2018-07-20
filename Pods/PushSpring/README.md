PushSpring SDK
==============

The PushSpring SDK is designed to be incredibly easy to integrate with your app.  Once it's integrated, it will begin sending usage information to our servers, which you can then use to define segments and send campaigns.

The SDK supports iOS 8.0+, is universal, and is built using ARC.  If you need support for an earlier iOS version, contact us at hello@pushspring.com .

Full integration instructions can be found at http://www.pushspring.com/developer .

### Questions and Support

If you have any Questions, Bugs, or Support Issues, please log them as GitHub issues, or contact us at hello@pushspring.com .  We'd love to hear your feedback and ideas!

### Changelog
v4.0.6  Xcode 9.3 changes.

v4.0.5  Adding an isGDPR method that will return true if PushSpring is treating the device as being connected through a GDPR region.

v4.0.4  Supporting iOS 8 again.

v4.0.3  Bug fixes. In addition to the static library, we are now packaging the SDK as the PushSpring.framework through the 'PushSpring/Framework' cocoapods subspec.

v4.0.2  iOS 11 changes.

v4.0.1  Fixed a case where getCustomerInsights doesn't call the completionHandler. Added a missing weak framework (CoreTelephony) to the pod spec. Without it the app developer would need to add it manually.

v4.0.0  Changes to getCustomerInsights. New initialization method that reads the PushSpring API key from the Info.plist.

v3.0.6  Minor bug fixes.

v3.0.5  Support setting a customer birth year. Minimum deployment target set to 8.0 as required by Apple in Xcode 8. Bug fixes.

v3.0.4  Fixes a minor issue with queuing.

v3.0.3  Updates and minor fixes.

v3.0.2  Bug fixes.

v3.0.1  Fixes to bitcode support. Small optimizations in networking layer.

v3.0.0  Fully supports iOS 9. Changed the minimum supported version to iOS 7. Added a new getCustomerInsights method.
