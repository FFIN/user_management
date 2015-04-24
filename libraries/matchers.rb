if defined?(ChefSpec)
  def create_usermsg(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:user_management, :create, resource_name)
  end

  def remove_usermsg(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:user_management, :remove, resource_name)
  end
end
