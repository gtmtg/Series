# Series

iPhone/iPad app that can solve calculus series problems using handwriting recognition and the WolframAlpha API.

This project requires [CocoaPods](https://cocoapods.org) for dependencies. To compile,

1. Clone the repository
2. Run ```pod install``` in the project directory
3. Register for the [Wolfram Alpha API](http://products.wolframalpha.com/api) and add your App ID at the top of ```Series/ViewController.h```
4. Register for the [MyScript ATK](https://developer.myscript.com/pricing/atk)
5. Download the MyScript iOS SDK files ```ATKCore.framework```, ```ATKMath.framework```, ```ATKMathWidget.bundle```, and ```ATKMathWidget.framework``` and place them in the ```Series/``` directory
6. Download the MyScript ATK certificate files ```MyCertificate.h``` and ```MyCertificate.m``` and place them in the ```Series/``` directory
7. Open ```Series.xcworkspace``` in Xcode, build the target "Series," and run on your device
