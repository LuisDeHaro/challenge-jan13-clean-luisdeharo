# Luis de Haro - deharodk@gmail.com
# Jan 13, 2021

class ParagraphHighlight

	attr_accessor :content, :highlights

	Breakline = "\n\n"

	def initialize(content_p, highlights_p)
		self.content = content_p
		self.highlights = highlights_p
	end

	def perform
		
		# returning an error string if we don't have proper inputs
		throw "error, the inputs are not valid" if self.content.to_s.empty? || !self.highlights.kind_of?(Array)

		paragraphs = self.content.split( Breakline ).map{ |pg| pg.delete( Breakline ) }

		html = ""

		# iterating over the paragraphs
		paragraphs.each_with_index do |pg,i|

			_output_paragraph = pg

			_word_by_word_content = pg.split(/[^[[:word:]]]+/).map.with_index { |w,i| { original_position: i, word: w } } 

			# selecting the hightlights that we can actually build by this particular paragraph
			self.highlights.select { |h| h[:start] < _word_by_word_content.size }.each do |hl|

				# assigning this to vars just for a better reading purpose, might change this for a prod env
				mark_tag_index_start = _word_by_word_content.index {|ix| ix[:original_position] == hl[:start] }
				mark_tag_index_end = _word_by_word_content.index {|ix| ix[:original_position] == hl[:end] + 1 }

				# injecting the highligth tags <mark> </mark>
				_word_by_word_content.insert( 
					mark_tag_index_start, 
					{ 
						original_position: -1, # dummy so it won't interfere with the original positions
						word: "<mark style='background-color: ##{Random.new.bytes(3).unpack("H*")[0]};' data-toggle='tooltip' data-placement='top' title='#{ hl[:comment] }'>" 
					}
				)

				_word_by_word_content.insert( 
					mark_tag_index_end.nil? ? _word_by_word_content.length : mark_tag_index_end, 
					{ 
						original_position: -1, # dummy so it won't interfere with the original positions
						word: "</mark>" 
					}
				)
				
				# joining the paragraph again
				_output_paragraph = _word_by_word_content.map{ |w| w[:word] }.join(' ')

			end

			# builing the final string
			html.concat( "<p>#{_output_paragraph}</p>" );

		end
		
		# getting an html boilerplate in order to write the generated paragraphs
		boilerplate_html = File.read("boilerplate.html")

		# creating the output file HTML
		File.open("output.html", "w") do |f|     
			f.write(boilerplate_html.gsub("{{TO-BE-REPLACED}}", html))   
		end

	end # end of method

end # end of class