# Clear existing data to avoid duplicates
Alumn.destroy_all
Guardian.destroy_all
AlumnGuardian.destroy_all
Classroom.destroy_all
Discipline.destroy_all
Plan.destroy_all
PlanDiscipline.destroy_all
User.destroy_all
UserDiscipline.destroy_all
Lesson.destroy_all
Assistance.destroy_all
Product.destroy_all
Order.destroy_all
Payment.destroy_all
Subscription.destroy_all
SubscriptionPayment.destroy_all

# Create Alumns
alumn1 = Alumn.create!(name: "Gemma Isabella", last_name: "Rojas Ponce", birth_date: "2017-09-30", address: "Privada Rio Gandarilla 3247 Int 23 Stanza Cantabria CP: 80301", phone_number: nil, email: nil, is_active: true)
alumn2 = Alumn.create!(name: "Naomi", last_name: "De la O Gonzalez", birth_date: "2014-10-16", address: "Tucuman #3000 int. 26 Avellaneda", phone_number: nil, email: nil, is_active: true)

# Create Guardians
guardian1 = Guardian.create!(name: "Marcela", last_name: "Ponce Higuera", phone_number: "6671056095", email: "marxelita.83@gmail.com", is_active: true)
guardian2 = Guardian.create!(name: "Antonio", last_name: "Rojas Arenas", phone_number: "6673897584", email: nil, is_active: true)

# Create Alumn-Guardian Relationships
AlumnGuardian.create!(alumn: alumn1, guardian: guardian1)
AlumnGuardian.create!(alumn: alumn2, guardian: guardian2)

# Create Classrooms
classroom1 = Classroom.create!(name: "Studio A", description: "Main ballet studio with mirrors and barres", is_active: true)
classroom2 = Classroom.create!(name: "Studio B", description: "Smaller studio for private lessons", is_active: true)

# Create Disciplines
discipline1 = Discipline.create!(name: "Ballet", is_active: true)
discipline2 = Discipline.create!(name: "Contemporary Dance", is_active: true)

# Create Plans
plan1 = Plan.create!(name: "Monthly Ballet Plan", price: 100.0, subscription_duration: 30, tolerance_days: 5, is_active: true)
plan2 = Plan.create!(name: "Annual Dance Plan", price: 1000.0, subscription_duration: 365, tolerance_days: 10, is_active: true)

# Create Plan-Discipline Relationships
PlanDiscipline.create!(plan: plan1, discipline: discipline1)
PlanDiscipline.create!(plan: plan2, discipline: discipline2)

user1 = User.create(name: "German Eduardo", last_name: "Salazar Aranda", phone_number: "6671313845", email: "german_sjj4@hotmail.com", password_digest: BCrypt::Password.create('25061996sayan5'), password: "25061996sayan5")
user2 = User.create(name: "Paulina", last_name: "Ibarra Humaran", phone_number: "6677654321", email: "paulinahumaran@gmail.com", password_digest: BCrypt::Password.create('Mayone99'), password: "Mayone99")

# Create User-Discipline Relationships
UserDiscipline.create!(user: user1, discipline: discipline1)
UserDiscipline.create!(user: user2, discipline: discipline2)

# Create Lessons
lesson1 = Lesson.create!(plan: plan1, user: user1, classroom: classroom1, schedule: DateTime.now + 1.week, status: 0, discipline: discipline1)
lesson2 = Lesson.create!(plan: plan2, user: user2, classroom: classroom2, schedule: DateTime.now + 2.weeks, status: 0, discipline: discipline2)

# Create Assistances
Assistance.create!(lesson: lesson1, alumn: alumn1)
Assistance.create!(lesson: lesson2, alumn: alumn2)

# Create Products
product1 = Product.create!(name: "Ballet Shoes", price: 25.99, description: "High-quality leather ballet shoes", is_active: true)
product2 = Product.create!(name: "Leotard", price: 35.50, description: "Stretchy leotard for ballet practice", is_active: true)

# Create Orders
order1 = Order.create!(user: user1, alumn: alumn1, product: product1, quantity: 1, status: 0, total: 25.99, description: "Ballet Shoes for Gemma")
order2 = Order.create!(user: user2, alumn: alumn2, product: product2, quantity: 2, status: 0, total: 71.00, description: "Leotards for Naomi")

# Create Payments
payment1 = Payment.create!(user: user1, alumn: alumn1, total: 25.99)
payment2 = Payment.create!(user: user2, alumn: alumn2, total: 71.00)

# Associate Payments with Orders
order1.update!(payment: payment1)
order2.update!(payment: payment2)

# Create Subscriptions
subscription1 = Subscription.create!(plan: plan1, alumn: alumn1, due_date: Date.today + 30.days, status: 0, last_payment_date: Date.today)
subscription2 = Subscription.create!(plan: plan2, alumn: alumn2, due_date: Date.today + 365.days, status: 0, last_payment_date: Date.today)

# Create Subscription-Payment Relationships
SubscriptionPayment.create!(subscription: subscription1, payment: payment1)
SubscriptionPayment.create!(subscription: subscription2, payment: payment2)

puts "Seeded data successfully!"
