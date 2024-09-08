if not GLOBAL_COUNTER then
  GLOBAL_COUNTER = { figure = 0 }
end

return {
  ['image-ext'] = function(args, kwargs, meta) 
    quarto.log.output("Loading image-ext extension", "args", args, "kwargs", kwargs)    


    
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
    local captiontype = pandoc.utils.stringify(kwargs["captiontype"])
    if captiontype == '' then
      captiontype = nil
    end

    if not captiontype or captiontype == 'figure' then
      GLOBAL_COUNTER.figure = GLOBAL_COUNTER.figure + 1
      quarto.log.output("GLOBAL_COUNTER.figure = " .. GLOBAL_COUNTER.figure)
    end

    local figureoverride = pandoc.utils.stringify(kwargs["figureoverride"])
    if figureoverride == '' then
      figureoverride = nil
    end
    if figureoverride then
      GLOBAL_COUNTER.figure = figureoverride
    end


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
        local elements = {
          pandoc.RawInline('html', '<div class="quarto-figure quarto-figure-center">\n<figure class="figure">\n<p>')          
        }
        if url then
          table.insert(elements, pandoc.RawInline('html', '<a href="' .. url .. '">'))
        end
        table.insert(elements, pandoc.RawInline('html', '<img src="' .. img .. '" class="img-fluid figure-img" alt="'))
        
        table.insert(elements, pandoc.Str(caption))
        table.insert(elements, pandoc.RawInline('html', '"></p>\n<figcaption class="caption">'))
        if not captiontype or captiontype == 'figure' then
          table.insert(elements, pandoc.Str("Figure " .. GLOBAL_COUNTER.figure .. ". "))
        end
        table.insert(elements, pandoc.Str(caption))
        table.insert(elements, pandoc.RawInline('html', '</figcaption>'))
        if url then
          table.insert(elements, pandoc.RawInline('html', '</a>'))
        end
        table.insert(elements, pandoc.RawInline('html','\n</figure>\n</div>'))

        return pandoc.Para(elements)
    elseif quarto.doc.is_format("latex") then
      -- if there's a url, we need to append it to the print caption for those who are working on a printed out version of the pdf. We also need to make the image clickable.
      
      

      local latex = {
        pandoc.RawInline('latex', '\\begin{figure}[H]\n\\centering\n')
      }
      if url then
        table.insert(latex,pandoc.RawInline('latex','\\href{'))
        table.insert(latex,pandoc.Str(url))
        table.insert(latex,pandoc.RawInline('latex','}{'))
      end
      table.insert(latex,pandoc.RawInline('latex','\\includegraphics[width=\\textwidth]{' .. img .. '}\n'))
      if url then
        table.insert(latex,pandoc.RawInline('latex','}'))
      end
      if captiontype then
        table.insert(latex,pandoc.RawInline('latex','\n\\captionsetup{type='.. captiontype ..'}'))      
      end
      table.insert(latex,pandoc.RawInline('latex','\n\\caption{'))
      table.insert(latex, pandoc.Str(print_caption))
      if url then
        table.insert(latex, pandoc.RawInline('latex', " \\href{" .. url .. "}{(" .. url .. ")}"))
      end
      table.insert(latex, pandoc.RawInline('latex','}\n\\end{figure}'))
      
      -- else
      --   latex = '\\begin{figure}[H]\n\\centering\n\\includegraphics[width=\\textwidth]{' .. img .. '}\n\\caption{' .. print_caption .. '}\n\\end{figure}'
      -- end
      -- quarto.log.output("latex = ", latex)

      return pandoc.Para(latex)
    
    end
    return pandoc.Str("[" .. img .. (caption ~= "" and " -- " .. caption or "") .. "]")

    
    
  end
}
