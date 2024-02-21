
return {
  ['image-ext'] = function(args, kwargs, meta) 
    quarto.log.output("Loading image-ext extension", "args", args, "kwargs", kwargs)
    -- return pandoc.Str("Hello from Image-ext!")
    
    local img = pandoc.utils.stringify(kwargs["img"])
    if img == '' then
      quarto.log.error("image-ext extension requires img argument")
      return nil
    end
    local caption = pandoc.utils.stringify(kwargs["caption"])
    if caption == '' then
      quarto.log.error("image-ext extension requires caption argument")
      return nil
    end
    local print_caption = pandoc.utils.stringify(kwargs["print_caption"])
    if print_caption == '' then
      print_caption = caption
    end
    local url = pandoc.utils.stringify(kwargs["url"])
    
    if url == '' then
      url = nil
      quarto.log.output("img = '" .. img .. "'", "caption = '" .. caption .. "'", "print_caption = '" .. print_caption .. "'")
    else
      quarto.log.output("img = '" .. img .. "'", "caption = '" .. caption .. "'", "print_caption = '" .. print_caption .. "'", "url = '" .. url .. "'")
    end

    if quarto.doc.is_format("html") then
        --       <div class="quarto-figure quarto-figure-center">
        -- <figure class="figure">
        -- <p><a href="https://twitter.com/NOAASatellitePA/status/912368981784309760"><img src="issue03/johnson-a.png" class="img-fluid figure-img" alt="Suomi satellite images of Puerto Rico on 24 July 2017 and 24 September 2017. Image credit: NOAA National Environmental Satellite, Data, and Information Service (NESDIS)."></a></p>
        -- <figcaption>Suomi satellite images of Puerto Rico on 24 July 2017 and 24 September 2017. Image credit: NOAA National Environmental Satellite, Data, and Information Service (NESDIS).</figcaption>
        -- </figure>
        -- </div>

        if url then
          html = '<div class="quarto-figure quarto-figure-center">\n<figure class="figure">\n<p><a href="' .. url .. '"><img src="' .. img .. '" class="img-fluid figure-img" alt="' .. caption .. '"></p>\n<figcaption>' .. caption .. '</figcaption></a>\n</figure>\n</div>'
        else
          html = '<div class="quarto-figure quarto-figure-center">\n<figure class="figure">\n<p><img src="' .. img .. '" class="img-fluid figure-img" alt="' .. caption .. '"></p>\n<figcaption>' .. caption .. '</figcaption>\n</figure>\n</div>'
        end
        return pandoc.RawInline('html', html)
    elseif quarto.doc.is_format("latex") then
      -- if there's a url, we need to append it to the print caption for those who are working on a printed out version of the pdf. We also need to make the image clickable.
      if url then
        print_caption = print_caption .. " \\href{" .. url .. "}{(" .. url .. ")}"
        latex = '\\begin{figure}[H]\n\\centering\n\\href{' .. url .. '}{\\includegraphics[width=\\textwidth]{' .. img .. '}}\n\\caption{' .. print_caption .. '}\n\\end{figure}'
      else
        latex = '\\begin{figure}[H]\n\\centering\n\\includegraphics[width=\\textwidth]{' .. img .. '}\n\\caption{' .. print_caption .. '}\n\\end{figure}'
      end
      quarto.log.output("latex = ", latex)

      return pandoc.RawInline('latex', latex)
    
    end
    return pandoc.Str("[" .. img .. (caption ~= "" and " -- " .. caption or "") .. "]")

    
    
  end
}
