module Cms::Routes
  def routes_for_bcms_s3
    namespace(:cms) do |cms|
      #cms.content_blocks :s3s
    end  
  end
end
