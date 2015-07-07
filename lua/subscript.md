# 下标从1开始

-  在lua中，数组下标从1开始计数。

-  在初始化一个数组的时候，若不显式地用键值对方式赋值，则会默认用数字作为下标，从1开始。
```lua
color={first="red", "blue", third="green", "yellow"} <--> {["first"]="red", [1]="blue", ["third"]="green", [2]="yellow"}
```


-  如果想要强制将数组下标从 0 开始：
```
colors = {[0]="red", "green", "blue"}
```

####  注意：不推荐数组下标从 0 开始，否则很多标准库不能使用。

