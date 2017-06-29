<h1>TJLSessionManager</h1>
A manager class for the new MultipeerConnectivity framework. Wraps up a bunch of delegate methods and makes it so you don't have to worry about clogging up your view controller with a ton of delegate methods, or worry about rolling your own manager class. Also provides a block based API rather than the normal delegate methods.

<h2>Installation</h2>
<hr>
the prefered method is [CocoaPods](http://www.cocoapods.org), just put `pod 'TJLSessionManager', '1.0.2'` into your podfile. If you don't want to use cocoapods, just grab the files in the Source folder, drop them into your project and then `#import "TJLSessionManager.h"`. I am using the new Xcode modules, so you should not need to add any frameworks to your project.
<h2>Usage</h2>
<hr>
There are several things that you need to do to connect two or more users with the Multipeer framework, and the basic steps of using TJLSessionManager are outlined below.<br>
`-initWithDisplayName:`<br>
One device will advertise,<br>
`-advertiseForBrowserViewController`<br>
One device will browse, this uses the Apple provided browser view controller.<br>
`-browseWithControllerInViewController:connected:canceled:`<br>
This will be called when someone wants to connect.<br>
`-didReceiveInvitationFromPeer:`<br>
This will give you the status of the connection.<br>
`-peerConnectionStatusOnMainQueue:block:`<br>
Then you have a block where you will receive data that is sent from the connected peer.<br>
`-receiveDataOnMainQueue:block:`<br>
and thats the basics of it. The header is well documented, so you can check there as well for any further info.<br>


<h1>License</h1>
If you use TJLSessionManager and you like it, feel free to let me know, <terry@ploverproductions.com>. If you have any issue or want to make improvements, submit a pull request.<br><br>

The MIT License (MIT)
Copyright (c) 2014 Terry Lewis II

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
<br><br>
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
<br><br>
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

