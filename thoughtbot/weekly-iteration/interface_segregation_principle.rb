class Article < ActiveRecord::Base
  def self.latest
    order('created_at DESC').limit(5)
  end

  def self.popular
    order('popularity DESC').limit(5)
  end
end

class FrontPage
  def initialize(articles, user)
    @articles = articles
    @user = user
  end

  def articles
    @articles.latest + @article.popular
  end
end

class FrontPage
  def initialize(articles, user)
    @articles = articles
    @user = user
  end

  def articles
    @articles.latest +
      @article.popular.where('created_at >= ?', 2.weeks.ago)
  end
end

class ArticleCache
  def initialize(articles, cache)
    @articles = articles
    @cache = cache
  end

  def latest
    @articles.last
  end

  def popular
    @cache.fetch('popular_articles') do
      @articles.popular
    end
  end
end

class ArticleQuery
  include Enumerable

  def initialize(relation)
    @relation = relation
  end

  def each(&block)
    @relation.each(&block)
  end

  def latest
    self.class.new @relation.order('created_at DESC').limit(5)
  end

  def popular
    self.class.new @relation.order('popularity DESC').limit(5)
  end
end
