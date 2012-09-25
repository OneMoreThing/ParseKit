ParseKit
========

ParseKit allows to use Anypic (iOS app by parse.com/anypic) self-hosted replacing the Parse.com framework with DataKit (open source) framework.
ParseKit was developed to test DataKit, currently ParseKit is still inefficient but useful at least to evaluate the use of DataKit.

Thanks to Erik for your great work with DataKit and thanks to Parse.com team for Anypic.

**Author**: Denis Berton [@DenisBerton](https://twitter.com/DenisBerton)

To use Anypic self-hosted with ParseKit you need to follow the following steps:

-download Anypic repository

-remove Parse framework from Anypic

-add DataKit project (DataKit.xcodeproj) on framework group in Anypic

-add Facebook framework with DeprecatedHeaders folder on framework group in Anypic

-copy ParseKit folder in Anypic External folder and add folder on External group in Anypic project

-add "-all_load" in "Other Linker Flags" for Anypic target

-add libDataKit.a in "Link Binary With Libraries" section for Anypic target

-add "-fno-objc-arc" for SCFacebook.m in "Compile Sources" section for Anypic target

-change Prefix.pch import of Parse framework as #import "Parse.h"

-rename protocol PF_FBRequestDelegate in AppDelegate.h as FBRequestDelegate

-change entityId property in DKEntity.h from readonly to strong

-follow the instruction in DataKit to create your backend server (localhost or for example on Amazon with an ec2 bitnami node.js image connected to mongohq service)

-configure ParseKit for Anypic in AppDelegate.m with your self-hosted server parameters and facebook app id 

    //(Parse is a wrapper for DKManager class in DataKit, see DataKit instruction)
    [Parse setApplicationId:@"http://localhost:3000" clientKey:@"66e5977931c7e48aa89c9da0ae5d3ffdff7f1a58e6819cbea062dda1fa050296"];    
    //(For testing purpose use Hackbook app id to login with facebook)
    [PFFacebookUtils initializeWithApplicationId:@"210849718975311"];
    //(Fill the URL scheme in Info.plist with your fbFACEBOOK_APP_ID or with the Hackbook app id fb210849718975311 and the bundle identifier as com.facebook.samples.Hackbook)
    

See [FAQ](https://github.com/OneMoreThing/ParseKit/wiki/FAQ) page for common errors and resolution.


TODO:

-Develop an efficient way to implement Parse.com orQueryWithSubqueries and smooth table scrolling 

-Add push notifications and async messaging (currently not implemented in DataKit), probably with node-apn

-Add ACL (currently not implemented in DataKit)

-Option to store/load images on Amazon S3 bucket
