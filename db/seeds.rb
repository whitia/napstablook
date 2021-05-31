# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create!(
  email: 'info@example.com',
  password: 'password'
)

categories = [
  { name: '国株', color: '#f8a291' },
  { name: '国債', color: '#f7e2b9' },
  { name: '国不', color: '#e0f7b2' },
  { name: '先株', color: '#9cf5b7' },
  { name: '先債', color: '#abfedd' },
  { name: '先不', color: '#c6f3f8' },
  { name: '新株', color: '#bcdbf7' },
  { name: '新債', color: '#ece2fe' },
  { name: '新不', color: '#c9bbf7' },
  { name: '他', color: '#f8c6e5' }
]

categories.each do |category|
  Category.create!(
    name: category[:name],
    color: category[:color]
  )
end