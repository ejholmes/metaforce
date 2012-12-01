shared_examples 'a client' do
  describe 'when the session id expires' do
    let(:response)  { HTTPI::Response.new(403, {}, '') }
    let(:exception) { Savon::SOAP::Fault.new(response) }

    before do
      client.send(:client).should_receive(:request).once.and_raise(exception)
      exception.stub(:message).and_return('INVALID_SESSION_ID')
    end

    context 'and no authentication handler is present' do
      it 'raises the exception' do
        expect { client.send(:request, :foo) }.to raise_error(exception)
      end
    end

    context 'and an authentication handler is present' do
      let(:authentication_handler) do
        Metaforce.configuration.authentication_handler = proc do |client, options|
          options = { session_id: 'foo' }
        end
      end

      after do
        Metaforce.configuration.authentication_handler = nil
      end

      it 'calls the authentication handler and resends the request' do
        client.send(:client).should_receive(:request).once.and_return(nil)
        authentication_handler.should_receive(:call).and_call_original
        client.send(:request, :foo)
      end
    end
  end
end
