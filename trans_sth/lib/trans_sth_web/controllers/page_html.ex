defmodule TransSthWeb.PageHTML do
  use TransSthWeb, :html

  embed_templates("page_html/*")
  embed_templates("show_html/*")
end
