require 'jekyll/ship/services/base'

RSpec.describe Jekyll::Ship::Services::Base do
  describe '#build_command' do
    context 'with no options specified' do
      subject { described_class.new.send(:build_command) }
      it { is_expected.to eq 'bundle exec jekyll build' }
    end

    context 'with a destination passed in' do
      subject { described_class.new.send(:build_command, destination: 'foo') }
      it { is_expected.to eq 'bundle exec jekyll build -d foo' }
    end
  end
end
