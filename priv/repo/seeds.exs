# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     TeacherCoop.Repo.insert!(%TeacherCoop.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias TeacherCoop.Repo
alias TeacherCoop.Accounts.User
alias TeacherCoop.Workspace.Groups.WorkingGroup
alias TeacherCoop.Workspace.Groups.Membership
alias TeacherCoop.Workspace.Connection
alias TeacherCoop.Workspace.Document

user =
  Repo.insert!(%User{
    email: "admin@localhost.fr",
    fullname: "Robert De Fouca"
  })

user2 =
  Repo.insert!(%User{
    email: "gemini@localhost.fr",
    fullname: "Gemini Jupiter"
  })

for {email, fullname} <- [
      {"marie@localhost.fr", "Marie Curie"},
      {"albert@localhost.fr", "Albert Einstein"},
      {"ada@localhost.fr", "Ada Lovelace"},
      {"nikola@localhost.fr", "Nikola Tesla"},
      {"linus@localhost.fr", "Linus Torvalds"},
      {"grace@localhost.fr", "Grace Hopper"},
      {"alan@localhost.fr", "Alan Turing"},
      {"richard@localhost.fr", "Richard Feynman"},
      {"sophie@localhost.fr", "Sophie Germain"},
      {"charles@localhost.fr", "Charles Darwin"},
      {"elena@localhost.fr", "Elena Vasquez"},
      {"omar@localhost.fr", "Omar Khalid"},
      {"priya@localhost.fr", "Priya Sharma"},
      {"lucas@localhost.fr", "Lucas Moreau"},
      {"amara@localhost.fr", "Amara Diallo"},
      {"yuki@localhost.fr", "Yuki Tanaka"},
      {"felix@localhost.fr", "Felix Schneider"},
      {"ingrid@localhost.fr", "Ingrid Larsen"},
      {"marco@localhost.fr", "Marco Ricci"},
      {"chloe@localhost.fr", "Chloe Dubois"}
    ] do
  user_tmp = Repo.insert!(%User{email: email, fullname: fullname})
end

Repo.insert!(%Connection{
  user1_id: user2.id,
  user2_id: user.id,
  state: "accepted"
})

group =
  Repo.insert!(%WorkingGroup{
    name: "Hello, World"
  })

Repo.insert!(%Membership{
  user_id: user.id,
  working_group_id: group.id,
  role: "admin"
})

Repo.insert!(%Document{
  title: "Introduction to Algebra",
  description: "A comprehensive introduction to algebraic concepts for high school students, covering equations, inequalities, and functions.",
  public: true,
  tags: ["mathematics", "algebra", "high-school"],
  goals: ["Understand linear equations", "Solve inequalities", "Graph functions"],
  user_id: user.id
})

Repo.insert!(%Document{
  title: "French Revolution Overview",
  description: "An in-depth overview of the French Revolution, its causes, key events, and lasting impact on modern democracy and society.",
  public: true,
  tags: ["history", "france", "revolution"],
  goals: ["Identify causes of the Revolution", "Describe key figures", "Analyze long-term consequences"],
  user_id: user.id
})

Repo.insert!(%Document{
  title: "Introduction to Python Programming",
  description: "A beginner-friendly guide to Python programming, covering variables, control flow, functions, and basic data structures.",
  public: false,
  tags: ["computer-science", "python", "programming"],
  goals: ["Write basic Python scripts", "Use lists and dictionaries", "Define and call functions"],
  user_id: user.id
})

Repo.insert!(%Document{
  title: "Photosynthesis and Plant Biology",
  description: "An exploration of how plants convert sunlight into energy, covering chlorophyll, the light and dark reactions, and the role of plants in ecosystems.",
  public: true,
  tags: ["biology", "plants", "science"],
  goals: ["Explain the photosynthesis process", "Identify key molecules involved", "Relate photosynthesis to the carbon cycle"],
  user_id: user.id
})

Repo.insert!(%Document{
  title: "World Geography: Continents and Oceans",
  description: "A foundational geography resource covering the seven continents, five oceans, major mountain ranges, and river systems of the world.",
  public: true,
  tags: ["geography", "world", "primary"],
  goals: ["Name and locate all continents", "Identify major oceans", "Describe key physical features"],
  user_id: user.id
})

Repo.insert!(%Document{
  title: "Shakespeare: Romeo and Juliet",
  description: "A guided reading and analysis of Shakespeare's Romeo and Juliet, including themes, character study, and historical context of Elizabethan theatre.",
  public: false,
  tags: ["literature", "shakespeare", "drama"],
  goals: ["Analyze major themes", "Study key characters", "Understand Elizabethan language"],
  user_id: user.id
})

Repo.insert!(%Document{
  title: "Newton's Laws of Motion",
  description: "A detailed lesson on Newton's three laws of motion with real-world examples, experiments, and problem sets to reinforce understanding.",
  public: true,
  tags: ["physics", "mechanics", "science"],
  goals: ["State and apply each of Newton's laws", "Solve basic force problems", "Connect laws to everyday phenomena"],
  user_id: user.id
})

Repo.insert!(%Document{
  title: "Introduction to Music Theory",
  description: "A practical introduction to music theory for beginners, covering notes, scales, chords, rhythm, and how to read sheet music.",
  public: false,
  tags: ["music", "arts", "theory"],
  goals: ["Read basic sheet music", "Identify major and minor scales", "Construct simple chords"],
  user_id: user.id
})
