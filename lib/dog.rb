class Dog
    attr_accessor :name, :breed, :id

    def initialize(id: nil, name:, breed:)
        @id=  id
        @name = name
        @breed = breed
    end

    def self.create_table
        DB[:conn].execute("DROP TABLE IF EXISTS dogs;")
        sql = <<-SQL
        CREATE TABLE dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP table dogs;")
    end

    def save
        if self.id
            self
        else
            sql = <<-SQL
            INSERT INTO dogs (name, breed) VALUES (?, ?)
            SQL
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            self
        end
    end

    def self.create(hash_attr)
        dog = self.new(name: hash_attr[:name], breed: hash_attr[:breed])
        dog.save
    end

    def self.new_from_db(a)
        self.new(id: a[0], name: a[1], breed: a[2])
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
        SQL
        a_a = DB[:conn].execute(sql, id).first
        self.new(id: a_a[0], name: a_a[1], breed: [2])
    end

    def self.find_or_create_by(hash)
        sql = <<-SQL
          SELECT * FROM dogs WHERE name = ? AND breed = ?
        SQL
        arr = DB[:conn].execute(sql, hash[:name], hash[:breed]).flatten
        if !arr.empty? #if true, then dog does exist in database
          dog = self.new(id: arr[0], name: arr[1], breed: arr[2])
        else
          dog = self.create(hash)
        end
        dog
      end

      def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ?
        SQL
        arr = DB[:conn].execute(sql, name).first
        self.new(id: arr[0], name: arr[1], breed: arr[2])
      end

      def update
        sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
        SQL
        dog = DB[:conn].execute(sql, self.id).first
        update = <<-SQL
        UPDATE dogs SET name = ?, breed = ? WHERE id = ?
        SQL
        DB[:conn].execute(update, self.name, self.breed, self.id)
      end

end
