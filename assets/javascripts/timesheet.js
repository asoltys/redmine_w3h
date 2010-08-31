Event.observe(window, 'load', function() { 
  $$('tr.deliverable').each(function(e) { 
    e.observe('click', function(e) {
      e.element().up('table').select('tr.activity').each(function(e) {
        e.toggle();
      });
    });
  });

  $$('tr.activity').each(function(e) { 
    e.observe('click', function(e) {
      e.element().up('tbody').next().toggle();
    });
  });
});
