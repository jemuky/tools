# Chat

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

  创建项目参见: https://hexdocs.pm/phoenix/overview.html 

# 准备步骤
1. 安装Erlang24以上、Elixir 1.14以上  
2. 安装hex包管理器: `mix local.hex`  
3. 安装phoenix应用管理器: `mix archive.install hex phx_new`  
4. 安装`postgresql`   
5. linux安装`inotify-tools (for Linux users)`用来实时重载  
6. 使用`mix ecto.create`创建不存在的数据库

# 创建项目
`mix phx.new hello`

