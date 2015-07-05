# 调试
调试是一个程序猿非常重要的能力，人写的程序总会有bug，所以需要debug。***如何方便和快速的定位bug***，是我们讨论的重点，只要bug能定位，解决就不是问题。

对于熟悉用Visual Studio和Eclipse这些强大的集成开发环境的来做C＋＋和Java的同学来说，OpenResty的debug要原始很多，但是对于习惯Python开发的同学来说，又是那么的熟悉。张银奎有本[《软件调试》](http://www.amazon.cn/%E8%BD%AF%E4%BB%B6%E8%B0%83%E8%AF%95-Software-Debugging-%E5%BC%A0%E9%93%B6%E5%A5%8E/dp/B001AUKASG)的书，windows客户端程序猿应该都看过，大家可以去试读下，看看里面有多复杂:(

对于Openresty，坏消息是，没有单步调试这些玩意儿（我们尝试搞出来过ngx lua的单步调试，但是没人用...）;好消息是，它像Python一样，非常简单，不用复杂的技术，只靠print和log就能定位问题。
