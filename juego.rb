require 'rack'
require 'thin'
require 'haml'
  
  module PiedraPapelTijera
    class App
  
      def initialize(app = nil)
        @app = app
        @content_type = :html

	#Hash con las reglas de juego
        @defeat = {'piedra' => 'tijeras', 'papel' => 'piedra', 'tijera' => 'papel'}

	#Posibles opciones, piedra, papel o tijera.
        @throws = @defeat.keys
      end
  
      def call(env)
        req = Rack::Request.new(env)
  
        req.env.keys.sort.each { |x| puts "#{x} => #{req.env[x]}" }
  
	#Elección al azar por parte de la máquina
        computer_throw = @throws.sample
	#Elección del jugador a través del path_info
        player_throw = req.GET["choice"]

        answer = if !@throws.include?(player_throw)
            "Elija una de las siguientes:"
          elsif player_throw == computer_throw
            "Empataste con la máquina"
          elsif computer_throw == @defeat[player_throw]
            "Felicidades, ganaste; #{player_throw} gana #{computer_throw}"
          else
            "Lástima; #{computer_throw} gana #{player_throw}. Suerte la próxima vez"
          end

        engine = Haml::Engine.new File.open("views/index.html.haml").read
      
        res = Rack::Response.new
      
	resultado = {
          :choose => @choose,
          :answer => answer,
          :throws => @throws,
          :computer_throw => computer_throw,
          :player_throw => player_throw
        }
	
	
        res.write engine.render({},resultado)
        
        res.finish
      end # call
    end # App
  end # PiedraPapelTijera
  
  if $0 == __FILE__
    builder = Rack::Builder.new do
      use Rack::Static, :urls => ["/css", "/images"], :root => "public"
      use Rack::ShowExceptions
      use Rack::Lint
      run PiedraPapelTijera::App.new
    end

    Rack::Handler::Thin.run builder, :Port => 9000
  end
