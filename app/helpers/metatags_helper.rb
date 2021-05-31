module MetatagsHelper
  def default_meta_tags
    {
      site: 'Napstablook',
      title: '',
      reverse: true,
      charset: 'utf-8',
      description: 'Investment trust management service - You can manage own investment trust easily, also and simulate rebalancing.',
      keywords: '',
      canonical: request.original_url,
      separator: '-',
      og: {
        site_name: :site,
        title: :title,
        description: :description,
        type: 'website',
        url: request.original_url,
        locale: 'ja_JP',
      }
    }
  end
end