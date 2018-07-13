# :.Sum.:
__AntiEye__ is an experimental utiltary pack, designed to ease process of remote webcam access testing.  
Powered silmulatenously by HTML5 and .NET, it was designed with Windows support in mind.

# :.Parser.:
__Design:__ broswer-based converter, implemented in pure [CoffeeScript 2](https://coffeescript.org/v2/).  
__Usage:__ converting [ExpCamera](https://github.com/d38k8/expcamera) logs into commonly recognizable `ip:port user:pass` data format.  
__Dist:__ https://guevara-chan.github.io/AntiEye/parser/main.html (live version)  
__Extra:__ requires ES6 support to work properly.

# :.Checker.:
__Design:__ terminal-based utility, written in [Boo v0.9.7.0](https://github.com/boo-lang/boo) with auxiliary libraries from [Emgu CV](www.emgu.com) project.  
__Usage:__ mass-checking remote webcams through provided credentials list by taking videofeed or interface screenshots.  
__Dist:__ https://github.com/Guevara-chan/AntiEye/releases/download/v0.02/checker.zip (latest release)
__Extra:__ requires .NET 4.0 and x64 Windows system to run.
