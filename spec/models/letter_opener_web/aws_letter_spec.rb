# frozen_string_literal: true

RSpec.describe LetterOpenerWeb::AwsLetter do
  subject { described_class.new(id: letter_id) }

  let(:aws_access_key_id)     { 'aws_access_key_id' }
  let(:aws_secret_access_key) { 'aws_secret_access_key' }
  let(:aws_region)            { 'aws_region' }
  let(:aws_bucket)            { 'aws_bucket' }
  let(:letter_id)             { 'letter_id' }

  let(:s3_client) do
    instance_double(Aws::S3::Client)
  end

  before :each do
    LetterOpenerWeb.configure do |config|
      config.aws_access_key_id = aws_access_key_id
      config.aws_secret_access_key = aws_secret_access_key
      config.aws_region = aws_region
      config.aws_bucket = aws_bucket
    end

    expect(Aws::S3::Client)
      .to receive(:new)
      .with(
        access_key_id: aws_access_key_id,
        secret_access_key: aws_secret_access_key,
        region: aws_region
      )
      .and_return(s3_client)
  end

  after :each do
    LetterOpenerWeb.reset!
  end

  describe '#delete' do
    let(:s3_content) { instance_double(Aws::S3::Types::Object, key: '123') }

    it 'does not remove letter if it does not exist' do
      expect(s3_client)
        .to receive(:list_objects_v2)
        .with(bucket: aws_bucket, prefix: letter_id)
        .and_return(
          instance_double(Aws::S3::Types::ListObjectsV2Output, contents: [])
        )
      expect(s3_client)
        .not_to receive(:delete_objects)

      subject.delete
    end

    it 'removes letter if it exists' do
      expect(s3_client)
        .to receive(:list_objects_v2)
        .with(bucket: aws_bucket, prefix: letter_id)
        .and_return(
          instance_double(Aws::S3::Types::ListObjectsV2Output, contents: [s3_content])
        )
        .twice

      expect(s3_client)
        .to receive(:delete_objects)
        .with(
          bucket: aws_bucket,
          delete: {
            objects: [key: s3_content.key],
            quiet: false
          }
        )

      subject.delete
    end
  end

  describe '.destroy_all' do
    let(:s3_content) { instance_double(Aws::S3::Types::Object, key: '123') }

    it 'removes all letters' do
      expect(s3_client)
        .to receive(:list_objects_v2)
        .with(bucket: aws_bucket)
        .and_return(
          instance_double(Aws::S3::Types::ListObjectsV2Output, contents: [s3_content])
        )
      expect(s3_client)
        .to receive(:delete_objects)
        .with(
          bucket: aws_bucket,
          delete: {
            objects: [key: s3_content.key],
            quiet: false
          }
        )

      described_class.destroy_all
    end
  end

  describe '.search' do
    it 'returns all letters' do
      expect(s3_client)
        .to receive(:list_objects_v2)
        .with(bucket: aws_bucket, delimiter: '/')
        .and_return(
          instance_double(Aws::S3::Types::ListObjectsV2Output, common_prefixes: [
            instance_double(Aws::S3::Types::CommonPrefix, prefix: '1111_1111/')
          ])
        )

      letters = described_class.search

      expect(letters.size).to eq(1)
      expect(letters.first.id).to eq('1111_1111')
    end
  end

  describe '#valid?' do
    it 'returns true if the letter exists' do
      expect(s3_client)
        .to receive(:list_objects_v2)
        .with(bucket: aws_bucket, prefix: letter_id)
        .and_return(
          instance_double(Aws::S3::Types::ListObjectsV2Output, contents: [
            instance_double(Aws::S3::Types::Object)
          ])
        )

      expect(subject).to be_valid
    end

    it 'returns false if the letter does not exist' do
      expect(s3_client)
        .to receive(:list_objects_v2)
        .with(bucket: aws_bucket, prefix: letter_id)
        .and_return(
          instance_double(Aws::S3::Types::ListObjectsV2Output, contents: [])
        )

      expect(subject).not_to be_valid
    end
  end

  describe '#attachments' do
    let(:s3_content)    { instance_double(Aws::S3::Types::Object, key: '123') }
    let(:presigned_url) { 'https://presigned-url' }
    let(:s3_bucket)     { instance_double(Aws::S3::Bucket, object: double) }
    let(:s3_object)     { instance_double(Aws::S3::Object, presigned_url: double) }

    it 'returns attachments with presigned urls' do
      expect(s3_client)
        .to receive(:list_objects_v2)
        .with(bucket: aws_bucket, prefix: "#{letter_id}/attachments/")
        .and_return(
          instance_double(Aws::S3::Types::ListObjectsV2Output, contents: [s3_content])
        )
      expect(Aws::S3::Bucket)
        .to receive(:new)
        .with(name: aws_bucket, client: s3_client)
        .and_return(s3_bucket)
      expect(s3_bucket)
        .to receive(:object)
        .with(s3_content.key)
        .and_return(s3_object)
      expect(s3_object)
        .to receive(:presigned_url)
        .with(:get, expires_in: 1.week.to_i)
        .and_return(presigned_url)
      
      expect(subject.attachments).to eq(s3_content.key => presigned_url)
    end
  end
end
