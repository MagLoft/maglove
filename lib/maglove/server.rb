module MagLove
  class Server
    include Commander::Methods
    attr_accessor :port, :root, :theme, :webrick
    
    def initialize(theme, port=3001)
      self.theme = theme
      self.port = port
      self.root = "dist/"
      
      # create server
      self.webrick = WEBrick::HTTPServer.new(
        Port: self.port,
        DocumentRoot: self.root,
        Logger: WEBrick::Log.new("/dev/null"),
        AccessLog: []
      )
      
      # prepare controller actions
      templates = theme_config(:templates, self.theme)
      templates.each do |template|
        mount("/#{template}") do |req, res|
          debug("▸ rendering template: #{template}")
          
          # set up dummy variables
          variables = {
            # image_url: "http://cdn.magloft.com/themes/medium-dark/images/static/bridge2.jpg",
            title: "Sneaky ways to snag the best seat on the plane",
            html: "<p><a href='https://www.yahoo.com/travel/author/leah-ginsberg'>Leah Ginsberg</a>, Lead Editor, Yahoo Travel<br/></p><figure class='tmblr-full' data-orig-height='337' data-orig-width='506'><img src='https://41.media.tumblr.com/cb21b8c906ca13ae62d8a4da603a557e/tumblr_inline_nr5m7tf8ag1tsssyh_540.jpg' data-orig-height='337' data-orig-width='506' alt='image'/></figure><p><i>Photo: Thinkstock</i></p><p>The best seat on the plane means different things to different people. According to a <a href='http://www.skyscanner.net/press-releases/skyscanner-reveals-perfect-seat-6a'>2012 Skyscanner survey</a>, seat 6A was a winner, taking into account that 46 percent of people prefer to be seated in the front of the plane, nearly 60 percent prefer window seats, and 62 percent want an even-numbered aisle.<br/></p><p>But whatever your personal preferences, travelers now have a ton of competition for coveted seats. Airlines predict they will have 222 million passengers between June 1 and Aug. 31 this year, which is 2.4 million passengers a day, and 4.5 percent more than last summer, <a href='http://hosted.ap.org/dynamic/stories/U/US_ON_THE_MONEY_FLYING_TOGETHER?SITE=AP&amp;SECTION=HOME&amp;TEMPLATE=DEFAULT&amp;CTIME=2015-06-24-17-39-52'>according to the Associated Press</a>.</p><p>So how can you get the seat you really want on your next flight? Yahoo Travel got tips from the experts.</p><p><b>Do your homework.</b> </p><p>With sites like <a href='http://www.seatguru.com/'>SeatGuru.com</a> and <a href='http://seatexpert.com/'>SeatExpert.com</a> you can find out the important details about your seat choice — everything from how much leg room you’ll have to whether the seat reclines (some in front of exit rows don’t, even if they’re considered premium) to what kind of entertainment system there is to how close you’ll be to the gross lavatory or noisy galley. Site <a href='https://www.routehappy.com/'>Routehappy.com</a> allows you to sort by “Happiest,” which is determined by quality-of-life factors like newness of the jet, type of entertainment, size of seat, power outlets, food, etc. Seatguru.com also has a similar system to search flights using what it calls the “G-Factor.”</p><p><b><i>Related: <a href='https://www.yahoo.com/travel/the-top-ranked-travel-credit-cards-picked-by-the-120218818247.html'>Are You Enlightened or a Control Freak? What Your Airline Seat Choice Says About You</a></i></b></p><p><b>Book early and pick a seat assignment at the time of booking.</b></p><p>“Flights generally open 335 days before departure,” says Jami Counter, senior director of <a href='http://www.tripadvisor.com/CheapFlightsHome'>TripAdvisor Flights</a>, “but it’s often six or seven months before you see any activity.” If you get in early and book a seat, you’ll have the best choice of what’s available. Plus, you’ll probably pay less for your flight leaving, more budget room to upgrade to premium economy if you need to. According to site SeatGuru.com, “Even if your first choice seat is not available, select another option to ensure you have a seat assignment; it can usually be changed later.”</p><p><b>Sign up for open seat alerts. </b></p><p>Get a free account with <a href='http://seatexpert.com/contact_us.php'>ExpertFlyer.com</a> and you can set an alert to be notified via email when aisle and window seats become available on your flight. For 99 cents, you can set be notified when exit rows, two seats together, or specific seats become available on your flight. Information is available for Alaska Airlines, American Airlines, JetBlue Airways, United Airlines, and Virgin America but not for Delta and other smaller carriers.</p><p><b>Confirm your seat assignment the week you’re flying. </b></p><figure class='tmblr-full' data-orig-height='338' data-orig-width='507'><img src='https://41.media.tumblr.com/439a3dc5c90b82912342ced11ede6fd5/tumblr_inline_nr5m81v5g71tsssyh_540.jpg' data-orig-height='338' data-orig-width='507' alt='image'/></figure><p><i>Photo: Thinkstock</i></p><p>According to SeatGuru.com, “Airlines sometimes switch the aircraft type close to the departure date due to load factors and maintenance. When these changes are made, pre-reserved seats are re-assigned and you could lose the seat you so carefully selected.” If you check ahead of time, you can select a new seat and head off any issues.</p><p><b>Check in early online. </b></p><p>Airlines often allow passengers to check in up to 24 hours before a flight, and the sooner you check in, the sooner you secure your seat. Plus, many airlines open up new seats (including coveted bulkhead and exit rows) anywhere from a week to the day before a flight, so better seats may be suddenly available at online check in. Caveat: if there’s no seat you’re happy with, it might make sense to hold off and check again when you arrive at the airport. Some airlines won’t let you change your seat after you have checked in online and printed your boarding pass.</p><p><b>Check for seats again with the gate agent. </b></p><figure class='tmblr-full' data-orig-height='368' data-orig-width='466'><img src='https://41.media.tumblr.com/3af3abffb9bfe55ea5fa9deaa2e0d075/tumblr_inline_nr5m872ES31tsssyh_540.jpg' data-orig-height='368' data-orig-width='466' alt='image'/></figure><p><i>Your gate agent may be able to work miracles if you’re nice. (Photo: Thinkstock)</i></p><p>If you’re polite, gate agents can often find seats you’re not aware of. Both better economy and premium economy seats may become available at the last minute as elite passengers from those seats are upgraded to business or first class. </p><p><b>When traveling with one other person, always book an aisle and a window. </b></p><p>It’s a way to help set yourself up for an empty seat in your row. “People are less likely to to book the middle,” explains George Hobica of <a href='http://www.airfarewatchdog.com/'>AirfareWatchdog.com</a>, “often making them the last to go.” And if the flight is full, chances are the person in the middle between you and your travel companion will probably be willing to swap for an aisle or window if you want to sit together, considering just about one percent of fliers surveyed prefer the middle, according to the Skyscanner study. </p><p><b><i>Related: <a href='https://www.yahoo.com/travel/7-secrets-i-learned-sitting-next-to-a-pilot-on-my-107997069027.html'>Best Seat on the Plane: 7 Secrets I Learned Sitting Next to a Pilot on My Las Flight</a></i></b></p><p><b>Pay to upgrade with miles or money. </b></p><p>With new rules for many airline loyalty programs, it can be very hard to use miles to buy a ticket, but you can use them for a seat upgrade, even if it’s just to premium economy. “I think it’s a really good way to use your miles,” says Hobica. And it can be worth it to pay cash to upgrade, too — 10 to 15 percent of the ticket price is a great value, according to SeatGuru.com. This is especially true on long-haul international flights, where premium economy seats can feel almost like business class (just expect to pay more for those upgrades).</p><p><b>Fly at the right time and the right day of the week. </b></p><figure data-orig-height='129' data-orig-width='229'><img src='https://40.media.tumblr.com/499c8e1fa8b3684b4afc3730036550f8/tumblr_inline_nr5m8dx7yG1tsssyh_540.jpg' data-orig-height='129' data-orig-width='229' alt='image'/></figure><p><i>Photo: Thinkstock</i></p><p>If you’re flying domestic, Tuesday and Wednesday flights tend to be less busy, as do flights in the middle of the day and late at night, says Counter. You have a better chance of getting an emptier flight with more seat choice and maybe even an empty seat or two in your row. If you’re really lucky, you may snag what they call a “repositioning flight” — a flight that’s main objective is getting an aircraft back to where it needs to be for its next flight — and they can be more empty. Though you can’t be sure whether a flight is repositioning, one tell may be a huge wide-body plane flying a domestic route.</p><p><b>Use strategy to pick rows that will fill up last. </b></p><p>According to <a href='http://travelcodex.com/2015/04/how-to-pick-a-seat-in-coach-for-international-travel/'>Travel Codex</a>, if your plane configuration is 3-3-3, choose either the left or right aisle or window seat, since middle seats in those rows are less desirable (center middle seats will likely fill up first since people there won’t have anyone climbing over them). If it’s a 2-3-2 or 2-4-2 set up, pick a seat that has as just one empty seat next to it — people are likely to pick a row with two empty seats as opposed to the one leftover middle seat. And since people who chose their own seats tends to pick the middle or front of the plane, and then gate agents assigning seats typically go from front to back and try to spread people out, middle seats in the back have a better chance of not being filled.  </p><p><b>Join loyalty programs and get a credit card the gives points for travel. </b></p><p>Membership does have its benefits, says Hobica. According to SeatGuru.com, airlines often allow their customers with elite status to pre-book preferred seats. But even if you don’t fly one airline enough to reach special status, membership still looks better than no membership. You can also rack up miles on credit cards and shopping partners that provide points and use them to upgrade.</p><p><b><i>Related: <a href='https://www.yahoo.com/travel/the-top-ranked-travel-credit-cards-picked-by-the-120218818247.html'>The Best Rewards Credit Cards for Travel</a></i></b></p><p><b>WATCH: Flying Singapore Airlines in First Class for an Hour Ruined My Life</b></p><p>In this episode of A Broad Abroad on Yahoo Travel, Paula Froelich is upgraded to First Class on Singapore Airlines and discovers that for her, air travel will never be the same!</p><figure class='tmblr-embed tmblr-full' data-provider='yahoo' data-orig-width='320' data-orig-height='180' data-url='https%3A%2F%2Fscreen.yahoo.com%2Ffirst-class-broad-abroad-181008113.html'><iframe width='540' height='303' src='https://screen.yahoo.com/first-class-broad-abroad-181008113.html?format=embed' frameborder='0'></iframe></figure><p><b>Let Yahoo Travel inspire you every day. Hang out with us on </b><a href='https://www.facebook.com/yahootravel'><b>Facebook</b></a><b>, </b><a href='https://twitter.com/yahootravel'><b>Twitter</b></a><b>, </b><a href='http://instagram.com/yahootravel'><b>Instagram</b></a><b>, and </b><a href='http://www.pinterest.com/yahootravel'><b>Pinterest.</b></a>  <b>Watch Yahoo Travel’s original series “</b><a href='https://www.yahoo.com/travel/tagged/a-broad-abroad'><b>A Broad Abroad</b></a><b>.”</b></p><div class='sponlogo'><a href='https://www.yahoo.com/travel/'><img src='https://s.yimg.com/dh/ap/default/150129/Yahoo_travel_logo_resized.png' alt='image'/></a> Yahoo Travel</div>",
            original_url: "http://travelinspirations.yahoo.com/post/123527610591/sneaky-ways-to-snag-the-best-seat-on-the-plane",
            tags: "1197772589,Trip Tips,Yahoo Travel,Leah Ginsberg,aeroplane,plane,tips,seats",
            post_type: "text"
          }
          
          # render template
          engine = Haml::Engine.new(theme_contents("templates/#{template}.haml", self.theme))
          contents = engine.render(Object.new, variables)
          
          # render editor view
          engine = Haml::Engine.new(View.editor)
          res.body = engine.render(Object.new, theme: self.theme, contents: contents, templates: templates, template: template)
        end
      end
    end
    
    def mount_template(path, view, options={})
      mount(path) do |req, res|
        engine = Haml::Engine.new(parse_view(view))
        res.body = engine.render(Object.new, options)
      end
    end
    
    def mount(path, &block)
      self.webrick.mount_proc(path, &block)
    end
    
    def run!
      trap 'INT' do 
        self.webrick.shutdown
      end
      self.webrick.start
    end
    
  end
end
