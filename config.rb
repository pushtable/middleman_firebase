# Activate and configure extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions

activate :autoprefixer do |prefix|
  prefix.browsers = "last 2 versions"
end

# TODO Enter your PushTable API Key and project settings
API_KEY = "..."
PROJECT_ID = "..."
PROJECT_PATH = "..."
PER_PAGE = 3

activate :data_source do |c|
  c.root  = "http://localhost:9000/api/cdn/#{PROJECT_ID}/"
  c.sources = [
    {
      alias: "articles",
      path: "#{PROJECT_PATH}?auth=#{API_KEY}",
      type: :json
    }
  ]
end

ignore 'directory.html'
data.articles.each_slice(PER_PAGE).with_index do |articles, page_index|

  puts '---ARTICLES', articles

  def next_page
    true
  end

  def prev_page
    false
  end

  proxy "index.html", "directory.html", locals: {
                                    page_index: page_index,
                                    articles: articles.map {|article| article[1]},
                                    next_page: next_page,
                                    prev_page: prev_page
                                  } if page_index == 0

  proxy "pages/#{page_index}.html", "directory.html", locals: {
                                    page_index: page_index,
                                    articles: articles[1],
                                    next_page: next_page,
                                    prev_page: prev_page
                                  }
end

ignore 'article.html'
data.articles.each do |key, article|
  proxy "articles/#{to_slug(article.title || key)}.html", "article.html", locals: { page_data: article }
end

# Layouts
# https://middlemanapp.com/basics/layouts/

# Per-page layout changes
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

# With alternative layout
# page '/path/to/file.html', layout: 'other_layout'

# Proxy pages
# https://middlemanapp.com/advanced/dynamic-pages/

# proxy(
#   '/this-page-has-no-template.html',
#   '/template-file.html',
#   locals: {
#     which_fake_page: 'Rendering a fake page with a local variable'
#   },
# )

# Helpers
# Methods defined in the helpers block are available in templates
# https://middlemanapp.com/basics/helper-methods/

# helpers do
#   def some_helper
#     'Helping'
#   end
# end

def to_slug(title)
  title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
end
# Build-specific configuration
# https://middlemanapp.com/advanced/configuration/#environment-specific-settings

# configure :build do
#   activate :minify_css
#   activate :minify_javascript
# end
