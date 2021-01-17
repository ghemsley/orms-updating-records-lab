require_relative '../config/environment.rb'

class Student
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :id, :name, :grade

  def initialize(name, grade, id = nil)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS students;
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if id
      update
    else
      sql = <<-SQL
        INSERT OR IGNORE INTO students (name, grade)
        VALUES (?, ?);
      SQL
      DB[:conn].execute(sql, name, grade)

      sql = <<-SQL
        SELECT last_insert_rowid() FROM students;
      SQL
      @id = DB[:conn].execute(sql)[0][0]
    end
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?;
    SQL

    DB[:conn].execute(sql, name, grade, id)
  end

  def self.create(name, grade)
    student = new(name, grade)
    student.name = name
    student.grade = grade
    student.save
    student
  end

  def self.new_from_db(row)
    new(row[1], row[2], row[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1;
    SQL
    row = DB[:conn].execute(sql, name).first
    new_from_db(row)
  end
end
