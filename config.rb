# Activate and configure extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions

activate :autoprefixer do |prefix|
  prefix.browsers = "last 2 versions"
end

# TODO Enter your PushTable API Key and project settings
API_KEY = ""
PROJECT_ID = ""
COLLECTION_ID = "articles" # TODO Update this to where your data is stored
PER_PAGE = 3

activate :data_source do |c|
  c.root  = "https://www.pushtable.com/api/firestore/#{PROJECT_ID}/"
  c.sources = [
    {
      alias: COLLECTION_ID,
      path: "#{COLLECTION_ID}?auth=#{API_KEY}",
      type: :json
    }
  ]
end

ignore 'directory.html'
data.articles.each_slice(PER_PAGE).with_index do |articles, page_index|

  proxy "index.html", "directory.html", locals: {
                                    page_index: page_index,
                                    articles: articles.map { |article|
                                      href = "/articles/#{to_slug(article.fields.try(:title))}.html"
                                      {href: href}.merge(article.fields)
                                    }
                                    # next_page: next_page,
                                    # prev_page: prev_page
                                  } if page_index == 0
end

ignore 'article.html'
data.articles.each do |article|
  proxy "articles/#{to_slug(article.fields.try(:title))}.html",
        "article.html",
        locals: { article: article.fields }
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
