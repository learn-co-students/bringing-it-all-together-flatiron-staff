class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def save
    insert
    assign_id
    self
  end

  def update
    sql = <<-SQL
      UPDATE dogs 
      SET name = ?, breed = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, @name, @breed, @id)
  end

  def self.create(hash)
    dog = new(hash)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL

    new_from_sql(sql, id)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL

    new_from_sql(sql, name)
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?
    SQL

    res = DB[:conn].execute(sql, name, breed)[0]
    res.nil? ? create({ name: name, breed: breed }) : new_from_db(res)
  end

  def self.new_from_db(row)
    dog = Dog.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)
  end

  def self.new_from_sql(sql, *args)
    row = DB[:conn].execute(sql, *args)[0]
    new_from_db(row)
  end

  private

  def insert
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, @name, @breed)
  end

  def assign_id
    find_id = <<-SQL
      SELECT id
      FROM dogs
      ORDER BY id DESC
      LIMIT 1
    SQL

    @id = DB[:conn].execute(find_id)[0][0]
  end
end