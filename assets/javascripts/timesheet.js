Event.observe(window, 'load', function() { 
  $$('tr.user').each(function(e) { 
    e.observe('click', function(e) {
      var row = e.element().up('tr');
      toggleRow(row);
      row.up('tbody').nextSiblings().each(function(e) {
        if (e.classNames().include('user_end')) {
          throw $break;
        }

        row.classNames().include('collapsed') ? e.hide() : e.show();
      });
    });
  });


  $$('tr.deliverable').each(function(e) { 
    e.observe('click', function(e) {
      var row = e.element().up('tr');
      toggleRow(row);
      row.up('tbody').nextSiblings().each(function(e) {
        if (e.classNames().include('deliverable_end')) {
          throw $break;
        }

        row.classNames().include('collapsed') ? e.hide() : e.show();
      });
    });
  });

  $$('tr.activity').each(function(e) { 
    e.observe('click', function(e) {
      var row = e.element().up('tr');
      toggleRow(row);

      e.element().up('tbody').next().toggle();
    });
  });
});

function toggleRow(row) {
  row.classNames().include('collapsed') ? row.removeClassName('collapsed') : row.addClassName('collapsed');

  if (row.classNames().include('collapsed')) {
    row.select('img.toggle').first().src = '/images/arrow_collapsed.png';
  }
  else {
    row.select('img.toggle').first().src = '/images/arrow_expanded.png';
  }
}
