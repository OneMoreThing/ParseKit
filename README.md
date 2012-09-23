ParseKit
========

ParseKit allows to use Anypic (ios app by parse.com/anypic) self-hosted replacing the Parse.com framework with DataKit (open source) framework.
ParseKit was developed to test DataKit, currently ParseKit is still inefficient but useful at least to evaluate the use of DataKit.

Thanks to Erik for your great work with DataKit and thanks to Parse.com team for Anypic.

**Author**: Denis Berton [@DenisBerton](https://twitter.com/DenisBerton)

To use Anypic self-hosted with ParseKit you need to follow the following steps:

-download Anypic repository

-remove Parse framework from Anypic

-add DataKit framework in Anypic

-add Facebook framework with DeprecatedHeaders folder

-add "-all_load" in Other Linker Flags for Anypic target

-add "-fno-objc-arc" for SCFacebook.m in Compile Sources section for Anypic target

-change Prefix.pch import of Parse framework as #import "Parse.h"

-replace protocol name PF_FBRequestDelegate in AppDelegate.h as FBRequestDelegate

-change entityId property in DKEntity.h from readonly to strong

-follow the instruction in DataKit to create your backend server (localhost or for example on Amazon with an ec2 bitnami node.js image connected to mongohq service)


TODO:

-Develop an efficient way to implement Parse.com orQueryWithSubqueries and smooth table scrolling 

-Add push notifications and async messaging (currently not implemented in DataKit), probably with Slanger

-Add ACL (currently not implemented in DataKit)

