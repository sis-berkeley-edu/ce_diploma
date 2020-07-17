module CeDiploma
  class SingleSignOn
    require 'digest'
    require 'openssl'

    def initialize(options = {})
      @sso_base_url = options[:sso_base_url]
      @client_id = options[:client_id]
      @client_number = options[:client_number]
      @mask_1 = options[:mask_1]
      @student_id = options[:student_id]
    end

    def single_sign_on_url
      @sso_base_url + '/' + hex_key + '/' + @client_number
    end

    def hex_key
      encrypted_hex_string = encrypt_to_hex(plain_text_student_id)
      @client_id + encrypted_hex_string + '|P'
    end

    # Student ID + pipe symbol + UTC DateTime is used to prevent "replay attacks"
    def plain_text_student_id
      @student_id.to_s + "|" + utc_date_time;
    end

    def utc_date_time
      Time.now.utc.strftime('%Y-%m-%d %H:%M:%S')
    end

    # Only use the first 16 chars (16 bytes) of mask1 for AES128
    def private_key_16_string
      @mask_1[0..15]
    end

    def encrypt_to_hex(plain_text_student_id)
      encrypted_message = openssl_encrypt(plain_text_student_id, private_key_16_string, openssl_iv)
      cipher_hex_string = bin_to_hex(encrypted_message)
      iv_hex_string = bin_to_hex(openssl_iv)
      iv_hex_string + cipher_hex_string
    end

    def decrypt_from_hex(hex_encrypted_payload)
      encrypted_payload = hex_to_bin(hex_encrypted_payload)
      iv = encrypted_payload[0..15]
      data = encrypted_payload[16..encrypted_payload.length]
      openssl_decrypt(data, private_key_16_string, iv)
    end

    def openssl_encrypt(msg, key, iv)
      openssl_cipher.encrypt
      openssl_cipher.key = key
      openssl_cipher.iv = iv
      openssl_cipher.update(msg) + openssl_cipher.final
    end

    def openssl_decrypt(encrypted_cipher, key, iv)
      openssl_cipher.decrypt
      openssl_cipher.key = key
      openssl_cipher.iv = iv
      openssl_cipher.update(encrypted_cipher) + openssl_cipher.final
    end

    # converts binary string to hex
    def bin_to_hex(s)
      # s.each_byte.map { |b| b.to_s(16) }.join
      s.each_byte.map { |b| b.to_s(16).rjust(2, '0') }.join
    end

    # converts hexadecimal to binary
    def hex_to_bin(s)
      s.scan(/../).map { |x| x.hex.chr }.join
    end

    # generates and stores random initialization vector
    def openssl_iv
      @openssl_iv ||= openssl_cipher.random_iv
    end

    # sets initialization vector
    def openssl_iv=(iv_string)
      openssl_cipher.iv = iv_string
      @openssl_iv = iv_string
    end

    def openssl_cipher
      @openssl_cipher ||= OpenSSL::Cipher::AES128.new(:CBC)
    end
  end
end
