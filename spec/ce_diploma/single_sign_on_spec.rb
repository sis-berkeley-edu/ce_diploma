require 'ce_diploma/single_sign_on'

RSpec.describe CeDiploma::SingleSignOn do
  require 'base64'

  let(:sso_properties) do
    {
      sso_base_url: 'https://www.example.com/Account/ERLSSO',
      client_id: '123ABC0F-1B2C-9876-AF19-555566667777',
      client_number: '1234',
      mask_1: '1!2@3#4$5%6^7&8*9(0)1!2@3#4$5%6^',
      student_id: '654321'
    }
  end
  let(:initialization_vector) { "\x90\tv\x9C\x7F0\x99O=\xE2\x14\xDFz\x99W\xED" }

  subject { described_class.new(sso_properties) }

  it 'provides accessors for all attributes' do
    subject.sso_base_url = 'http://www.example.com/Account/ERLSSOABC123'
    expect(subject.sso_base_url).to eq 'http://www.example.com/Account/ERLSSOABC123'
    subject.client_id = 'test-client-id'
    expect(subject.client_id).to eq 'test-client-id'
    subject.client_number = '4321'
    expect(subject.client_number).to eq '4321'
    subject.mask_1 = '&8*9(0)1!2@GvBhJb'
    expect(subject.mask_1).to eq '&8*9(0)1!2@GvBhJb'
    subject.student_id = '987654'
    expect(subject.student_id).to eq '987654'
  end


  describe '#enable_test_mode' do
    it 'sets base url string to test server' do
      subject.enable_test_mode
      expect(subject.sso_base_url).to eq 'https://test.secure.cecredentialtrust.com/Account/ERLSSO'
    end
  end

  describe '#enable_live_mode' do
    it 'sets base url string to test server' do
      subject.enable_live_mode
      expect(subject.sso_base_url).to eq 'https://secure.cecredentialtrust.com/Account/ERLSSO'
    end
  end

  describe '#single_sign_on_url' do
    before { allow(subject).to receive(:hex_key).and_return('4567') }
    it 'returns combination of SSO base url, hex key, and client number' do
      expect(subject.single_sign_on_url).to eq 'https://www.example.com/Account/ERLSSO/4567/1234'
    end
  end

  describe '#hex_key' do
    before { allow(subject).to receive(:encrypt_to_hex).and_return('thehexstring') }
    it 'returns combination of client id, encrypted hex string, and encryption method signifier' do
      expect(subject.hex_key).to eq '123ABC0F-1B2C-9876-AF19-555566667777thehexstring|P'
    end
  end

  describe '#plain_text_student_id' do
    it 'returns student id with current UTC date time string appended' do
      date_time = Time.now.utc.strftime('%Y-%m-%d %H:%M:%S')
      expect(subject.plain_text_student_id).to eq "654321|#{date_time}"
    end
  end

  describe '#private_key_16_string' do
    it 'returns first 16 characters of mask1 for AES128 encryption' do
      expect(subject.private_key_16_string).to eq '1!2@3#4$5%6^7&8*'
    end
  end

  describe '#encrypt_to_hex' do
    let(:plain_text_student_id) { '654321|2020-07-17 00:09:10' }
    it 'returns hexadecimal representation of encrypted message' do
      subject.openssl_iv = initialization_vector
      result = subject.encrypt_to_hex(plain_text_student_id)
      expect(result).to eq '9009769c7f30994f3de214df7a9957ed41b3c8f9a97248dfb603ca4778e83582388210105b85e20b4088f9ae6798c5b1'
    end
  end

  describe '#decrypt_from_hex' do
    let(:hex_encrypted_payload) { '9009769c7f30994f3de214df7a9957ed41b3c8f9a97248dfb603ca4778e83582388210105b85e20b4088f9ae6798c5b1' }
    it 'returns unencrypted payload' do
      subject.openssl_iv = initialization_vector
      result = subject.decrypt_from_hex(hex_encrypted_payload)
      expect(result).to eq '654321|2020-07-17 00:09:10'
    end
  end

  describe '#bin_to_hex' do
    let(:base64_encoded_cipher) { "jGiJHoMkQ87du1Zhf115zppI4IVpxAprde4mT3cnA64=\n" }
    it 'converts binary string to hexidecimal' do
      binary_cipher = Base64.decode64(base64_encoded_cipher)
      result = subject.bin_to_hex(binary_cipher)
      expect(result).to eq "8c68891e832443ceddbb56617f5d79ce9a48e08569c40a6b75ee264f772703ae"
    end
  end

  describe '#hex_to_bin' do
    let(:hexadecimal_string) { "8c68891e832443ceddbb56617f5d79ce9a48e08569c40a6b75ee264f772703ae" }
    it 'converts binary string to hexidecimal' do
      binary_cipher = subject.hex_to_bin(hexadecimal_string)
      base64_encoded_cipher = Base64.encode64(binary_cipher)
      expect(base64_encoded_cipher).to eq "jGiJHoMkQ87du1Zhf115zppI4IVpxAprde4mT3cnA64=\n"
    end
  end

  describe '#openssl_encrypt' do
    let(:msg) { 'marry had a little lamb' }
    it 'encrypts data using AES128 CBC encryption' do
      key = subject.private_key_16_string
      encrypted_string = subject.openssl_encrypt(msg, key, initialization_vector)
      # convert to Base64 string for sake of assertion
      base64_encoded_string = Base64.encode64(encrypted_string)
      expect(base64_encoded_string).to eq "jGiJHoMkQ87du1Zhf115zppI4IVpxAprde4mT3cnA64=\n"
    end
  end

  describe '#openssl_decrypt' do
    let(:base64_encoded_cipher) { "oQNPWS8/rxU3Yq5L2/5/qqh3YNx2LMxvAnjEgg9/dgc=\n" }
    it 'decrypts data using AES128 CBC decryption' do
      cipher = Base64.decode64(base64_encoded_cipher)
      key = subject.private_key_16_string
      unencrypted_string = subject.openssl_decrypt(cipher, key, initialization_vector)
      expect(unencrypted_string).to eq "Hickory Dickory Dock"
    end
  end

  describe '#openssl_iv' do
    it 'returns random string for each instance' do
      instance_1 = described_class.new(sso_properties)
      instance_2 = described_class.new(sso_properties)
      expect(instance_1.openssl_iv).to_not eq instance_2.openssl_iv
    end
    it 'returns 16 character string' do
      expect(subject.openssl_iv.length).to eq 16
    end
    it 'returns same random iv string on every call' do
      result1 = subject.openssl_iv
      result2 = subject.openssl_iv
      expect(result1.object_id).to eq result2.object_id
    end
  end

  describe '#openssl_cipher' do
    let(:sixteen_char_key) { 'Thi$i$myK3y(*@#)' }
    let(:result) { subject.openssl_cipher }
    it 'returns cipher object configured for AES-128 encryption with Cipher Blocker Chaining (CBC)' do
      expect(result).to be_an_instance_of OpenSSL::Cipher::AES128
      expect(result.name).to eq 'AES-128-CBC'
    end

    it 'specifies expected initialization vector length' do
      expect(result.iv_len).to eq 16
    end

    it 'returns the same object reference every time' do
      result2 = subject.openssl_cipher
      expect(result.object_id).to eq result2.object_id
    end

    it 'rejects invalid key' do
      expect { result.key = "SecretPassword" }.to raise_error(ArgumentError, 'key must be 16 bytes')
    end

    it 'accepts 16 byte/character key' do
      expect(sixteen_char_key.bytesize).to eq 16
      expect { result.key = sixteen_char_key }.to_not raise_error
    end
  end

end
