module MagLoft
  class TypeloftTemplate < RemoteResource
    endpoint "api/maglove/v1/typeloft_templates"
    remote_attribute :id, :identifier, :title, :contents, :thumbnails, :public, :typeloft_theme_id, :user_id, :created_at, :updated_at
  end
end
