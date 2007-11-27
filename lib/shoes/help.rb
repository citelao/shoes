def dewikify_p(str)
  str = str.gsub(/\n+\s*/, " ").dump.
    gsub(/`(.+?)`/m, '", code("\1"), "').gsub(/\[\[BR\]\]/i, "\n").
    gsub(/'''(.+?)'''/m, '", strong("\1"), "').gsub(/''(.+?)''/m, '", em("\1"), "').
    gsub(/\[\[(\S+?) (.+?)\]\]/m, '", link("\2", :click => "\1"), "')
    # gsub(/\(\!\)/m, '<img src="/static/exclamation.png" />').
    # gsub(/\!\\(\S+\.png)\!/, '<img class="inline" src="/static/\1" />').
    # gsub(/\!(\S+\.png)\!/, '<img src="/static/\1" />')
  eval "[#{str}]"
end

def dewikify(str, intro = false)
  proc do
    paras = str.split(/\s*?(\{{3}(?:.+?)\}{3})|\n\n/m).reject { |x| x.empty? }
    if intro
      para *(dewikify_p(paras.shift) + [:size => 12, :weight => "bold"])
    end
    paras.map do |ps|
      if ps =~ /\{{3}(?:\s*\#![^\n]+)?(.+?)\}{3}/m
        stack { para code($1.strip), :size => 9, :margin => 12 }
      else
        case ps
        when /\A \* (.+)/m
          $1.split(/^ \* /).map { |x| para *dewikify_p(x) }
        when /\A==== (.+) ====/
          caption *dewikify_p($1)
        when /\A=== (.+) ===/
          tagline *dewikify_p($1)
        when /\A== (.+) ==/
          subtitle *dewikify_p($1)
        when /\A= (.+) =/
          title *dewikify_p($1)
        else
          para *dewikify_p(ps)
        end
      end
    end
  end
end

def Shoes.make_help_page(str)
  docs =
    (str.split(/^= (.+?) =/)[1..-1]/2).map do |k,v|
      sparts = v.split(/^== (.+?) ==/)
      sections = (sparts[1..-1]/2).map do |k2,v2|
        meth = v2.split(/^=== (.+?) ===/)
        [k2[/^(?:The )?([\-\w]+)/, 1],
         {'title' => k2,
          'description' => meth[0],
          'methods' => (meth[1..-1]/2).map { |_k,_v| [_k, _v] }}]
      end
      [k, {'description' => sparts[0], 'sections' => sections, 
         'class' => "toc" + k.downcase.gsub(/\W+/, '')}]
    end
  proc do
    style(Shoes::Code, :stroke => "#C30")
    style(Shoes::LinkHover, :stroke => green, :fill => nil)
    style(Shoes::Para, :size => 9)
    style(Shoes::Tagline, :size => 12, :weight => "bold", :stroke => "#eee", :fill => "#333", :margin => 6)

    @doc = 
      stack :margin => 20, :margin_left => 130, :margin_top => 106,
        &dewikify(docs[0][-1]['description'], true)
    stack :top => 0, :left => 0 do
      stack do
        background black
        @title = title docs[0][0], :stroke => white, :margin => 14,
          :weight => "bold"
      end
      @toc = {}
      stack :margin => 20, :width => 120 do
        docs.each do |sect_s, sect_h|
          sect_cls = sect_h['class']
          para strong(link(sect_s, :stroke => black) { 
              @toc.each { |k,v| v.send(k == sect_cls ? :show : :hide) }
              @title.replace sect_s
              @doc.clear(&dewikify(sect_h['description'], true)) 
            }), :size => 11
          @toc[sect_cls] =
            stack :hidden => @toc.empty? ? false : true do
              links = sect_h['sections'].map do |meth_s, meth_h|
                [link(meth_s) {
                  @title.replace meth_h['title']
                  @doc.clear(&dewikify(meth_h['description'], true)) 
                  @doc.append do
                    meth_h['methods'].each do |mname, expl|
                      stack { background "#333"; tagline mname, :margin => 4 }
                      instance_eval &dewikify(expl)
                    end
                  end
                }, "\n"]
              end.flatten
              links[-1] = {:size => 9}
              para *links
            end
        end
      end
    end
    image "static/shoes-icon.png", :top => 8, :right => 10,
      :width => 64, :height => 64
  end
rescue => e
  p e.message
  p e.class
end

Shoes::Help = Shoes.make_help_page <<-'END'
= Shoes =

Shoes is a tiny graphics toolkit. It's simple and straightforward. Shoes was born to be easy, it was made for newlyhacks. There's really nothing to it.

You see, the trivial Shoes program can be just one line:

{{{
 #!ruby
 Shoes.app { button("Click me!") { alert("I am so proud of you...") } }
}}}

And, ideally, Shoes programs will run on any of the major platforms out there. Microsoft Windows, Apple's Mac OS X, Linux and many others.

So, welcome to Shoes' built-in manual. This manual is a Shoes program itself, written in Ruby. This manual is unfinished, but I hope that it will be a complete reference in the near future.

==== What Can You Make With Shoes? ====

Well, you can make windowing applications. But Shoes is inspired by the web, so applications tend to use images and text layout rather than a lot of widgets. For example, Shoes doesn't come with tabbed controls or toolbars. Shoes is a ''tiny'' toolkit, remember?

Still, Shoes does have a few widgets like buttons and edit boxes. And many missing elements (like tabbed controls or toolbars) can be simulated with images and mouse events.

Shoes also has a very good art engine, for drawing with shapes and colors. In this way, Shoes is inspired by NodeBox and Processing, two very good languages for drawing animated graphics.

== Built-in Methods ==

These methods can be used anywhere throughout Shoes programs.

All of these commands are unusual because you don't attach them with a dot. 
'''Every other method in this manual must be attached to an object with a dot.'''
But these are built-in methods (also called: Kernel methods.) Which means no dot!

A common one is `puts`:

{{{
 #!ruby
 puts "No dots in sight"
}}}

Compare that to the method `reverse`, which isn't a Kernel method and is available with Arrays and Strings:

{{{
 #!ruby
 "Plaster of Paris".reverse
  #=> "siraP fo retsalP"
 [:dogs, :cows, :snakes].reverse
  #=> [:snakes, :cows, :dogs]
}}}

=== alert( message ) ===

Pops up a window containing a short message.

{{{
 #!ruby
 alert("I'm afraid I must interject!")
}}}

=== ask( message ) ===

Pops up a window and asks a question. For example, you may want to ask someone their name.

{{{
 #!ruby
 name = ask("Please, enter your name:")
}}}

When the above script is run, the person at the computer will see a window with a blank box for entering their name. The name will then be saved in the `name` variable.

=== ask_color(title: a String) ===

Pops up a color picker window. The program will wait for a color to be picked, then gives you 
back a Color object. See the `Color` help for some ways you can use this color.

{{{
 #!ruby
 backcolor = ask_color("Pick a background")
 Shoes.app do
  background backcolor
 end
}}}

=== ask_open_file() ===

Pops up an "Open file..." window. It's the standard window which show all of your folders and lets you select a file to open. Hands you back the name of the file.

{{{
 #!ruby
 filename = ask_open_file
 puts File.read(filename)
}}}

=== ask_save_file() ===

Pops up a "Save file..." window, similiar to `ask_open_file`, described above.

{{{
 #!ruby
 save_as = ask_save_file
}}}

=== confirm(question: a String) ===

Pops up a yes-or-no question. If the person at the computer, clicks '''yes''', you'll get back a `true`. If not, you'll get back `false`.

{{{
 #!ruby
 if confirm("Draw a circle?")
  oval :top => 0, :left => 0, :radius => 50
 end
}}}

=== exit() ===

Stops your program. Call this anytime you want to suddenly call it quits.

== The App Object ==

An App is a single window running code at a URL. When you switch URLs, a new App object is created and filled up with stacks, flows and other Shoes elements.

=== location() ===

Gets a string containing the URL of the current app.

= Slots =

Slots are boxes used to lay out images, text and so on. The two most common slots are `stacks` and `flows`. Slots can also be referred to as "boxes" or "canvases" in Shoes terminology.

Since the mouse wheel and PageUp and PageDown are so pervasive on every platform, vertical scrolling has really become the only overflow that matters. So, in Shoes, just as on the web, width is generally fixed. While height goes on and on.

Now, you can also just use specific widths and heights for everything, if you want. That'll take some math, but everything could be perfect.

Generally, I'd suggest using stacks and flows. The idea here is that you want to fill up a certain width with things, then advance down the page, filling up further widths. You can think of these as being analogous to HTML's "block" and "inline" styles. 

==== Stacks ====

A stack is simply a vertical stack of elements. Each element in a stack is placed directly under the element preceding it.

A stack is also shaped like a box. So if a stack is given a width of 250, that stack is itself an element which is 250 pixels wide. 

==== Flows ====

A flow will pack elements in as tightly as it can. A width will be filled, then will wrap beneath those elements. Text elements placed next to each other will appear as a single paragraph. Images and widgets will run together as a series.

Like the stack, a flow is a box. So stacks and flows can safely be embedded and, without respect to their contents, are identical. They just treat their contents differently.

Last thing: The Shoes window is a flow. 

== Art for Slots ==

Each slot is like a canvas, a blank surface which can be covered with an assortment of colored shapes or gradients.

Many common shapes can be drawn with methods like `oval` and `rect`.  You'll need to set up the paintbrush colors first, though.

The `stroke` command sets the line color.  And the `fill` command sets the color used to paint inside the lines.

{{{
 #!ruby
 Shoes.app do
   stroke red
   fill blue
   oval :top => 10, :left => 10,
     :radius => 100
 end
}}}

That code gives you a blue pie with a red line around it.  One-hundred pixels wide, placed just a few pixels
southeast of the window's upper left corner.

The `blue` and `red` methods above are Color objects.  See the section on Colors for more on how to mix
colors.

=== nofill() ===

Blanks the fill color, so that any shapes drawn will not be filled in.  Instead, shapes will have only a
lining, leaving the middle transparent.

=== nostroke() ===

Empties the line color.  Shapes drawn will have no outer line.  If `nofill` is also set, shapes drawn will
not be visible.

== Styles of a Slot ==

Like any other element, slots can be styled and customized when they are created.

To set the width of a stack to 150 pixels:

{{{
 #!ruby
 stack(:width => 150) { para "Now that's precision." }
}}}

Each style setting also has a method, which can be used to grab that particular setting.  (So,
like, the `width` method returns the width of the slot in pixels.)

=== height() ===

The vertical size of the slot in pixels.

=== scroll() ===

Is this slot allowed to show a scrollbar?  True or false.  The scrollbar will only appear if
the height of the slot is also fixed.

=== width() ===

The horizontal size of the slot in pixels.

= Elements =

Ah, here's the stuff of Shoes.  An element can be as simple as an oval shape.  Or as complex as
a video stream.  You've encountered all of these elements before in the Slots section of the
manual.

Once an element is created, you will often still want to change it.  To move it or hide it or get
rid of it.  You'll use the element's class to do that sort of stuff.

So, for example, use the `image` method of a Slot to place a PNG on the screen. The `image` method
gives you back an Image object. Use the methods of the Image object to change things up.

== Image ==

An image is a picture in PNG, JPEG or GIF format.  Shoes can resize images or flow them in with text.

To create an image, use the `image` method in a slot:

{{{
 #!ruby
 flow do
   para "Nice, nice, very nice.  Busy, busy, busy."
   image "static/disheveled.gif"
  end
}}}

=== height() ===

The vertical screen size of the image in pixels.  This is not the original size of the image.
If you have a 150x150 pixel image and you set the width to 50 pixels, this method will return
50.

=== width() ===

The horizontal screen size of the image in pixels.

END
