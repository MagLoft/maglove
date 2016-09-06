module MagLoft
  class TypeloftTheme < RemoteResource
    endpoint "api/maglove/v1/typeloft_themes"
    remote_attribute :id, :identifier, :name, :description, :widgets, :user_id, :screenshots, :active

    def typeloft_templates
      RemoteCollection.new(TypeloftTemplate, { typeloft_theme_id: self.id })
    end
  end
end
