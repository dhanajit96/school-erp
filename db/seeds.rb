# db/seeds.rb
require 'faker'

puts "🌱 Starting Database Seed..."

# 1. Clean the database
puts "🧹 Cleaning old data..."
Enrollment.destroy_all
Batch.destroy_all
Course.destroy_all
User.destroy_all
School.destroy_all

# 2. Create the Super Admin (System Owner)
puts "🚀 Creating Super Admin..."
User.create!(
  name: "Super Admin",
  email: "super.admin@konnector.ai", # Changed to avoid conflict
  password: "password123",
  role: :admin,
  school: nil # Now allowed after migration fix
)

# 3. Create Schools
puts "🏫 Creating Schools..."
schools = []
school_names = ["Konnector Tech Academy", "Odisha State Institute"]

school_names.each do |name|
  schools << School.create!(
    name: name,
    address: Faker::Address.full_address,
    subdomain: name.parameterize
  )
end

# 4. Create School Admins
puts "👨‍🏫 Creating School Admins..."

# Admin for School 1
User.create!(
  name: "Konnector Principal",
  email: "admin@konnector.ai", # This is the School Admin
  password: "password123",
  role: :school_admin,
  school: schools[0]
)

# Admin for School 2
User.create!(
  name: "Odisha Principal",
  email: "admin@odisha.edu",
  password: "password123",
  role: :school_admin,
  school: schools[1]
)

# 5. Create Courses and Batches
puts "📚 Creating Courses and Batches..."

schools.each do |school|
  3.times do
    course = Course.create!(
      name: Faker::Educator.course_name,
      description: Faker::Lorem.paragraph,
      school: school
    )

    # Create 2 batches per course
    2.times do |i|
      Batch.create!(
        name: "Batch #{('A'..'Z').to_a[i]} - #{Date.today.year}",
        start_date: Date.today + rand(1..10).days,
        end_date: Date.today + 3.months,
        course: course
      )
    end
  end
end

# 6. Create Students
puts "🎓 Creating Students & Enrollment Requests..."

konnector_school = schools[0]
batches = konnector_school.batches

20.times do |i|
  student = User.create!(
    name: Faker::Name.name,
    email: "student#{i+1}@konnector.ai",
    password: "password123",
    role: :student,
    school: konnector_school
  )

  # Randomly enroll some students
  random_batch = batches.sample
  status_scenario = rand(0..3) # 0-2: Enrolled, 3: Not enrolled

  if status_scenario < 3
    status_key = [:pending, :approved, :denied][status_scenario]
    
    Enrollment.create!(
      user: student,
      batch: random_batch,
      status: status_key,
      request_date: Time.now - rand(1..5).days
    )
  end
end

puts ""
puts "✅ Seeding Complete!"
puts "---------------------------------------------------------"
puts "🔑 Credentials:"
puts "1. SUPER ADMIN: super.admin@konnector.ai | password123"
puts "2. SCHOOL ADMIN: admin@konnector.ai      | password123"
puts "3. STUDENT:      student1@konnector.ai   | password123"
puts "---------------------------------------------------------"