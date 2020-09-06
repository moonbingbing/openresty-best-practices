# 如何只启动一个 timer 工作？

### 应用场景

整个 OpenResty 启动后，我们有时候需要后台处理某些动作，比如数据定期清理、同步数据等。而这个后台任务实例我们期望是唯一并且安全，这里的安全指的是所有 Nginx worker 任意 crash 任何一个，有机制合理保证后续 timer 依然可以正常工作。

这里需要给大家介绍一个重要 API [ngx.worker.id()](https://github.com/iresty/nginx-lua-module-zh-wiki#ngxworkerid)。

- **语法：**
    ```lua
    seq_id = ngx.worker.id()
    ```
- **作用描述：**
    返回当前 Nginx 工作进程的一个顺序数字（从 0 开始）。
    所以，如果工作进程总数是 N，那么该方法将返回 [0 ~ N-1] 区间中的一个数字（包含区间两端的数字）。

- **注意：** 该方法只对 Nginx 1.9.1+ 版本返回有意义的值。更早版本的 Nginx，将总是返回 `nil` 。

### 解决方案

通过 API 描述可以看到，我们可以用它来确定这个 worker 的内部身份，并且这个身份是相对稳定的。即使当前 Nginx 进程因为某些原因 crash 了，新 fork 出来的 Nginx worker 是会继承这个 worker id 的。

剩下的问题就比较简单了，完全可以把我们的 timer 绑定到某个特定的 worker 上，这样即可。
下面的例子，演示如何只在 worker.id 为 0 的进程上运行后台 timer。

```lua
init_worker_by_lua_block {
    local delay = 3  -- in seconds
    local new_timer = ngx.timer.at
    local log = ngx.log
    local ERR = ngx.ERR
    local check

    check = function(premature)
        if not premature then
            -- do the health check or other routine work
            local ok, err = new_timer(delay, check)
            if not ok then
                log(ERR, "failed to create timer: ", err)
                return
            end
        end
    end

    if 0 == ngx.worker.id() then
        local ok, err = new_timer(delay, check)
        if not ok then
            log(ERR, "failed to create timer: ", err)
            return
        end
    end
}
```

