module IframeUploader
  UPLOAD_KEY = "ajax_upload"
  FROM_INDEX   = "1"
  FROM_PALETTE = "2"

  def self.included(controller)
    controller.helper_method :ajax_upload?, :iframe_upload?
  end

  def self.palette_opt
    {UPLOAD_KEY => FROM_PALETTE}
  end

  def self.index_opt
    {UPLOAD_KEY => FROM_INDEX}
  end

  def iframe_upload?
    !!params[UPLOAD_KEY]
  end
  alias_method :ajax_upload?, :iframe_upload?
end

