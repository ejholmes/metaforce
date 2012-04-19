class Thor
	module Actions
		module CustomActions
			require 'highline'

			def masked_ask(question)
				password = HighLine.new.ask(question) { |q| q.echo = '*' }
			end

			def spinner(&block)
				return unless block_given?
				chars = %w{ | / - \\ }

				t = Thread.new { yield if block_given? }
				while t.alive?
					print chars[0]
					sleep 0.1
					print "\b"

					chars.push chars.shift
				end

				t.join
				t.value
			end

		end
	end
end