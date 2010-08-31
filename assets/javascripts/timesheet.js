Event.observe(window, 'load', function() { 
  $$('tr.snowcone').each(function(e) { 
    e.observe('click', function(e) {
      var row = e.element();
      row.classNames().include('hiding') ? row.removeClassName('hiding') : row.addClassName('hiding');
      row.up('tbody').nextSiblings().each(function(e) {
        if (e.classNames().include('user_end')) {
          throw $break;
        }

        row.classNames().include('hiding') ? e.hide() : e.show();
      });
    });
  });


  $$('tr.deliverable').each(function(e) { 
    e.observe('click', function(e) {
      var row = e.element();
      row.classNames().include('hiding') ? row.removeClassName('hiding') : row.addClassName('hiding');
      row.up('tbody').nextSiblings().each(function(e) {
        if (e.classNames().include('deliverable_end')) {
          throw $break;
        }

        row.classNames().include('hiding') ? e.hide() : e.show();
      });
    });
  });

  $$('tr.activity').each(function(e) { 
    e.observe('click', function(e) {
      e.element().up('tbody').next().toggle();
    });
  });
});
