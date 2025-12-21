class UserBlueprint < Blueprinter::Base
  identifier :id
  fields :name, :email, :role, :created_at

  association :school, blueprint: SchoolBlueprint
end
