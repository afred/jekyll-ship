RSpec.describe "Jekyll::Ship::Services::Base" do

  describe '#build_command' do
    context 'with no options specified' do
      it 'returns basic jekyll build command' do
        expect(subject.build_command).to eq 'bundle exec jekyll build'
      end
    end

    context 'with a destination passed in' do
      it 'returns jekyll build command with destination specified' do
        expect(subject.build_command(destination: 'foo')).to eq 'bundle exec jekyll build -d foo'
      end
    end
  end
end
