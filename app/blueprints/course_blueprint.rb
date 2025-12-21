class CourseBlueprint < Blueprinter::Base
  identifier :id
  fields :name, :description
  fields :created_at

  view :detail do
    association :batches, blueprint: -> { BatchBlueprint }
  end
end
