Event.observe(window, 'load', function() { 
  $$('tr.user td, tr.deliverable td, tr.activity td').each(function(td) { 
    td.observe('click', toggleRow);
  });

  $('expand').observe('click', function(e) {
    $$('table.list tr').each(expand);
  });

  $('collapse').observe('click', function(e) {
    $$('table.list tr').each(collapse);
    $$('table.list tr.user').invoke('show');
  });
});

function toggleRow(e) {
  var row = e.element().up('tr');
  var types = ['user', 'deliverable', 'activity', 'time_entry'];
  var child_row_class, ending_row_class;

  row.classNames().include('collapsed') ? expand(row) : collapse(row);
  row.show();

  for (i = 0; i < types.length - 1; ++i) {
    if (row.classNames().include(types[i])) {
      child_row_class = types[i+1];
      ending_row_class = types[i] + '_end';
    }
  }

  row.nextSiblings().each(function(e) {
    if (e.classNames().include(ending_row_class)) throw $break; 
    if (row.classNames().include('collapsed')) collapse(e);
    else if (e.classNames().include(child_row_class)) e.show();
  });
}

function collapse(row) {
  var img = row.select('img.toggle').first();
  row.hide();

  if (!img) return;

  row.addClassName('collapsed');
  img.src = '/images/arrow_collapsed.png';
}

function expand(row) {
  var img = row.select('img.toggle').first();
  row.show();

  if (!img) return;

  row.removeClassName('collapsed');
  img.src = '/images/arrow_expanded.png';
}
