shared_examples 'a client' do
  describe 'when the session id expires' do
    let(:exception) { Savon::SOAP::Fault.new(HTTPI::Response.new(403, {}, '')) }

    before do
      client.send(:client).should_receive(:request).once.and_raise(exception)
      exception.stub(:message).and_return('INVALID_SESSION_ID')
    end

    context 'and no authentication handler is present' do
      before do
        client.stub(:authentication_handler).and_return(nil)
      end

      it 'raises the exception' do
        expect { client.send(:request, :foo) }.to raise_error(exception)
      end
    end

    context 'and an authentication handler is present' do
      let(:handler) do
        proc { |client, options| { :session_id => 'foo' }  }
      end

      before do
        client.stub(:authentication_handler).and_return(handler)
      end

      it 'calls the authentication handler and resends the request' do
        response = double('response')
        response.stub(:body).and_return(Hashie::Mash.new(:foo_response => {:result => ''}))
        client.send(:client).should_receive(:request).once.and_return(response)
        handler.should_receive(:call).and_call_original
        client.send(:request, :foo)
        expect(client.send(:client).config.soap_header).to eq("ins0:SessionHeader"=>{"ins0:sessionId"=>"foo"})
      end
    end
  end
end
