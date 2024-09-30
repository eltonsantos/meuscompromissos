User.create!(email: 'admin@admin.com', password: '123456', name: 'Admin', hours_per_week: 40)
User.create!(email: 'elton@elton.com', password: '123456', name: 'Elton', hours_per_week: 40)

Category.create!(name: "Desenvolvimento") 

Commitment.create!(description: "Meu compromisso da semana", user_id: 1, progress: 0, active: 1, created_at: '2024-09-25 22:29:27.606529')