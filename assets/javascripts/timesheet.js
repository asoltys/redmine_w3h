Event.observe(window, 'load', function() { 
  $$('tr.deliverable').each(function(e) { 
    e.observe('click', function(e) {
      e.element().up('tbody').nextSiblings().each(function(e) {
        if (e.classNames().include('deliverable_end')) {
          throw $break;
        }

        if (!e.classNames().include('time_entries')) {
          e.toggle();
        }
      });
    });
  });

  $$('tr.activity').each(function(e) { 
    e.observe('click', function(e) {
      e.element().up('tbody').next().toggle();
    });
  });
});
