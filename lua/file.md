#文件操作

lua I/O库提供两种不同的方式处理文件：

1、隐式文件描述：设置一个默认的输入或输出文件，然后在这个文件上进行所有的输入或输出操作。所有的操作函数由io表提供。

>打开已经存在的test1.txt文件，并读取里面的内容

```lua
file = io.input("D:\\test1.txt")  --使用io.input()函数打开文件

repeat
    line = io.read()      --逐行读取内容，文件结束时返回nil
    if nil == line then
        break
    end
    print(line)
until (false)

io.close(file)       --关闭文件

-->output
my test file
hello
lua
```

>在test1.txt文件的最后添加一行"hello world"

```lua
file = io.open("D:\\test1.txt", "a+") --使用io.open()函数，以添加模式打开文件
io.output(file)                    --使用io.output()函数，设置默认输出文件            
io.write("\nhello world")          --使用io.write()函数，把内容写到文件     
io.close(file)               
```

在相应目录下打开test1.txt文件，查看文件内容发生的变化。

2、显示文件描述：使用file:XXX()函数方式进行操作,其中file为io.open()返回的文件句柄。

>打开已经存在的test2.txt文件，并读取里面的内容

```lua
file = io.open("D:\\test2.txt", "r")  --使用io.open()函数，以只读模式打开文件
 
for line in file:lines() do          --使用file:lines()函数逐行读取文件
   print(line)
end

file:close()

-->output
my test2
hello lua
```

>在test2.txt文件的最后添加一行"hello world"

```lua
file = io.open("D:\\test2.txt", "a")  --使用io.open()函数，以添加模式打开文件
file:write("\nhello world")       --使用file:open()函数，在文件的最后添加一行内容
file:close()
```

在相应目录下打开test2.txt文件，查看文件内容发生的变化。

###文件操作函数

####io.open (filename [, mode])
按指定的模式mode，打开一个文件名为filename的文件，成功则返回文件句柄，失败则返回nil加错误信息。模式：

|模式|含义|文件不存在时|
|:---:|:---:|:---:|
|"r"|读模式 (默认)|返回nil加错误信息|
|"w"|写模式|创建文件|
|"a"|添加模式|创建文件|
|"r+"|更新模式，保存之前的数据|返回nil加错误信息|
|"w+"|更新模式，清除之前的数据|创建文件|
|"a+"|添加更新模式，保存之前的数据,在文件尾进行添加|创建文件|

模式字符串后面可以有一个'b'，用于在某些系统中打开二进制文件。

####file:close ()
关闭文件。注意：当文件句柄被垃圾收集后，文件将自动关闭。句柄将变为一个不可预知的值。

####io.close ([file])
关闭文件，和file:close()的作用相同。没有参数file时，关闭默认输出文件。

####file:flush ()
把写入缓冲区的所有数据写入到文件file中。

####io.flush ()
相当于file:flush(),把写入缓冲区的所有数据写入到默认输出文件。


####io.input ([file])
当使用一个文件名调用时，打开这个文件（以文本模式），并设置文件句柄为默认输入文件；
当使用一个文件句柄调用时，设置此文件句柄为默认输入文件；
当不使用参数调用时，返回默认输入文件句柄。

####file:lines ()
返回一个迭代函数,每次调用将获得文件中的一行内容,当到文件尾时，将返回nil,但不关闭文件。

####io.lines ([filename])
打开指定的文件filename为读模式并返回一个迭代函数,每次调用将获得文件中的一行内容,当到文件尾时，将返回nil,并自动关闭文件。若不带参数时io.lines() 等价于io.input():lines(); 读取默认输入设备的内容，结束时不关闭文件。

####io.output ([file])
类似于io.input，但操作在默认输出文件上。

####file:read (···)
按指定的格式读取一个文件。按每个格式将返回一个字符串或数字,如果不能正确读取将返回nil,若没有指定格式将指默认按行方式进行读取。格式：

|格式|含义|
|:---:|:---|
|"*n"|读取一个数字|
|"*a"|从当前位置读取整个文件。若当前位置为文件尾，则返回空字符串|
|"*l"|读取下一行的内容。若为文件尾，则返回nil。(默认)|
|number|读取指定字节数的字符。若为文件尾，则返回nil。如果number为0,则返回空字符串，若为文件尾,则返回nil|

####io.read (···)
相当于io.input():read

####io.type (obj)
检测obj是否一个可用的文件句柄。如果obj是一个打开的文件句柄，则返回"file"；如果obj是一个已关闭的文件句柄，则返回"closed file"；如果obj不是一个文件句柄，则返回nil。

####file:write (···)
把每一个参数的值写入文件。参数必须为字符串或数字，若要输出其它值，则需通过tostring或string.format进行转换。

####io.write (···)
相当于io.output():write。

####file:seek ([whence] [, offset])
设置和获取当前文件位置,成功则返回最终的文件位置(按字节，相对于文件开头),失败则返回nil加错误信息。缺省时，whence默认为"cur"，offset默认为0。
参数whence：

|whence|含义|
|:---:|:---:|
|"set"|文件开始|
|"cur"|文件当前位置(默认)|
|"end"|文件结束|

####file:setvbuf (mode [, size])
设置输出文件的缓冲模式。模式：

|模式|含义|
|:---:|:---|
|"no"|没有缓冲，即直接输出|
|"full"|全缓冲，即当缓冲满后才进行输出操作(也可调用flush马上输出)|
|"line"|以行为单位，进行输出|
最后两种模式,size可以指定缓冲的大小(按字节)，忽略size将自动调整为最佳的大小。