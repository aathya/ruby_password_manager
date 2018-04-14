require 'openssl'
require 'base64'
require 'pry'
require 'json'

def decrypt(key)
  decipher = OpenSSL::Cipher::AES.new(256, :CBC)
  decipher.decrypt
  decipher.key = OpenSSL::Digest::SHA256.new.digest(key)
  encrypted_data = Base64.decode64(File.read(@file_path))
  pw_json = decipher.update(encrypted_data) + decipher.final
  puts 'Enter key for password from below'
  JSON.parse pw_json
end

def encrypt(key, values)
  cipher = OpenSSL::Cipher::AES.new(256, :CBC)
  cipher.encrypt
  cipher.key = OpenSSL::Digest::SHA256.new.digest(key)
  cipher.update(values.to_json) + cipher.final
end

def decrypt_passwords
  puts 'Enter the key phrase 🔑'
  key = gets.chomp
  pw_json = decrypt(key)
  if pw_json.size.positive?
    puts pw_json.keys.join(', ')
    show_passwords(pw_json)
  else
    puts 'There are no password available at this moment. Try inserting'
  end
end

def insert_passwords
  puts 'Enter the key phrase 🔑'
  key = gets.chomp
  pw_json = {}
  pw_json = decrypt(key) unless File.zero?(@file_path)
  name, username, password = get_new_password
  pw_json[name.to_s] = {'username': username, 'password': password}
  encrypted = encrypt(key, pw_json)
  File.truncate(@file_path, 0)
  open @file_path, "w" do |io|
    io.write Base64.encode64(encrypted)
  end
  puts 'Wola done dude!'
end

def get_new_password
  puts 'Enter the name for which you want to create:'
  name = gets.chomp
  puts "Enter the email or username for #{name}"
  username = gets.chomp
  puts "Enter password for #{username}"
  password = gets.chomp
  [name, username, password]
end

def show_passwords(pw_json)
  3.times do
    puts "You can view for three at a time or you may enter exit"
    key = gets.chomp
    if pw_json.keys.include?(key) && key != 'exit'
      puts "Your password for #{key} is"
      puts "Username: #{pw_json[key]['username']}"
      puts "Password: #{pw_json[key]['password']}"
    else
      exit
    end
  end
end

def check_decrypted_file_exists?
  unless File.exists? @file_path
    File.open(@file_path, "w") {}
  end
end

def check_file_is_empty?
  if File.zero?(@file_path)
    puts 'Looks like you are new to our app.'
    puts 'Start by inserting passwords. Enter a key phrase which will encrypt your passwords. Don\'t forget it.'
    insert_passwords
  end
end

#globals
@file_path = 'rpm.txt'

puts "Welcome to Ruby Password Manager ❤︎"
check_decrypted_file_exists?
check_file_is_empty?
puts "Enter 1 to decrypt your file and see passwords"
puts "Enter 2 to insert your passwords"
puts "Enter value: "

user_entered_value = gets.chomp

case user_entered_value
  when '1'
    decrypt_passwords
  when '2'
    insert_passwords
  else
    exit
end

