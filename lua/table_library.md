#table library
table库是由一些辅助函数构成的，这些函数将table作为数组来操作。
####table.concat (table [, sep [, i [, j]]])
对于元素是string或者number类型的表table，返回table[i]..sep..table[i+1] ··· sep..table[j]连接成的字符串。填充字符串sep默认为空白字符串。起始索引位置i默认为1，结束索引位置j默认是table的长度。如果i大于j，返回一个空字符串。
```lua
a = {1,3,5,"hello" }
print(table.concat(a))
print(table.concat(a,"|"))
print(table.concat(a," ",4,2))
print(table.concat(a," ",2,4))

-->output
135hello
1|3|5|hello

3 5 hello
```
####table.insert (table, [pos,] value)
在表table的pos索引位置插入value，其它元素向后移动到空的地方。pos的默认值是表的长度加一，即默认是插在表的最后。
```
a = {1,8}             --a[1] = 1,a[2] = 8
table.insert(a,1,3)   --在表索引为1处插入3
print(a[1],a[2],a[3])
table.insert(a,10)    --在表的最后插入10
print(a[1],a[2],a[3],a[4])

-->output
3	1	8
3	1	8	10
```
####table.maxn (table)
返回表table的最大索引编号；如果此表没有正的索引编号，返回0。
```lua
a = {}
a[-1] = 10
print(table.maxn(a))
a[5] = 10  
print(table.maxn(a))

-->output
0
5
```

####table.remove (table [, pos])
在表table中删除索引为pos（pos只能是number型）的元素，并返回这个被删除的元素，它后面所有元素的索引值都会减一。pos的默认值是表的长度，即默认是删除表的最后一个元素。
```lua
a = { 1,2,3,4}
print(table.remove(a,1)) --删除速索引为1的元素
print(a[1],a[2],a[3],a[4])

print(table.remove(a))   --删除最后一个元素
print(a[1],a[2],a[3],a[4])

-->output
1
2	3	4	nil
4
2	3	nil	nil
```

####table.sort (table [, comp])
按照给定的比较函数comp给表table排序，也就是从table[1]到table[n]，这里n表示table的长度。
比较函数有两个参数，如果希望第一个参数排在第二个的前面，就应该返回true，否则返回false。
如果比较函数comp没有给出，默认从小到大排序。
```lua
function compare(x,y) --从大到小排序
   return x > y    --如果第一个参数大于第二个就返回true，否则返回false
end

a = { 1,7,3,4,25}
table.sort(a)         --默认从小到大排序
print(a[1],a[2],a[3],a[4],a[5])
table.sort(a,compare) --使用比较函数进行排序
print(a[1],a[2],a[3],a[4],a[5])

-->output
1	3	4	7	25
25	7	4	3	1
```
