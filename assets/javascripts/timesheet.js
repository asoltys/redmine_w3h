Event.observe(window, 'load', function() { 
  $$('tr.activity td').each(function(e) { 
    e.observe('click', function(e) {
      e.element().up('tbody').next().select('tr').each(function(e) { 
        e.toggle() 
      });
    });
  });
});
